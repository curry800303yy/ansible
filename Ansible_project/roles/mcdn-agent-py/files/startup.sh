#!/bin/bash
CURDIR=$(cd $(dirname $0); pwd)
echo "Starting MCDN Agent Python Service from $CURDIR"
exec python3 $CURDIR/main.py --config $CURDIR/config.json
