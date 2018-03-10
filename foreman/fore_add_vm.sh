#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Your command line contains $# arguments but must have 2"
    exit 1
fi

NAME=$1
MAC=$2
HAMMER_PARAMS="host create"
ARCH="x86_64"
DOMAIN="kar.int"
OS="CentOS 7"
PARTITION="Kickstart default"
LOCATION="Default Location"
ORG="Default Organization"
# Update the below to fit your needs
PASSWD="Password"
MEDIUM="centos7-pulp"
SUBNET="vlan-3"
MODEL="VMware Virtual Platform"

/usr/bin/hammer $HAMMER_PARAMS --architecture "$ARCH" --domain "$DOMAIN" --operatingsystem "$OS" --partition-table "$PARTITION" --location "$LOCATION" --organization "$ORG" --name "$NAME" --root-password "$PASSWD" --medium "$MEDIUM" --mac=$MAC --subnet "$SUBNET" --model "$MODEL"
