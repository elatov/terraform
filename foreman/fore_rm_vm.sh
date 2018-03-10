#!/bin/bash
if [ $# -lt 1 ]; then
    echo "Your command line contains $# arguments but must have 1"
    exit 1
fi

NAME=$1
HAMMER_PARAMS="host delete"
DOMAIN="kar.int"

/usr/bin/hammer $HAMMER_PARAMS --name "$NAME.$DOMAIN"
