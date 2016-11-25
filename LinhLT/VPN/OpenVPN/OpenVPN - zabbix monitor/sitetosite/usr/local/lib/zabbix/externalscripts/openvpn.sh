#!/bin/bash
FPINGBIN="/usr/bin/fping"
ping_tunnel() {

    IP_DEST="$1"
    IP_SRC="$2"

        alive=`$FPINGBIN $IP_DEST -S$IP_SRC -r 1 | grep alive | wc -l`

        if [[ "$alive" -eq "0" ]]
        then
            echo 0
        else
            echo 1
        fi
}
if [ $# -eq 0 ];
then
   echo UNKNOWN - missing Arguments.
   exit 
else
   ping_tunnel $1 $2
fi
