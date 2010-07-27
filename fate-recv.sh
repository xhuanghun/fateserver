#! /bin/sh

set -e
export LC_ALL=C

die(){
    echo "$@"
    exit 1
}

test -n "$FATEDIR" || die "FATEDIR not set"

reptmp=$(mktemp -d)
trap 'rm -r $reptmp' EXIT
cd $reptmp

tar xzk

header=$(head -n1 report)
date=$(expr "$header" : 'fate:0:\([0-9]*\):')
slot=$(expr "$header" : 'fate:0:[0-9]*:\([A-Za-z0-9_.-]*\):')

test -n "$date" && test -n "$slot" || die "Invalid report header"

slotdir=$FATEDIR/$slot

if [ -d "$slotdir" ]; then
    owner=$(cat "$slotdir/owner")
    test "$owner" = "$FATE_USER" || die "Slot $slot owned by somebody else"
else
    mkdir "$slotdir"
    echo "$FATE_USER" >"$slotdir/owner"
fi

repdir=$slotdir/$date
mkdir $repdir
cp -p report *.log $repdir
rm -f $slotdir/latest
ln -s $date $slotdir/latest
