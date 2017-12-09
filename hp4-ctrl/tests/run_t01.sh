#!/bin/bash

MININET="$(cat /tmp/pts_mininet)"
CONTROLLER="$(cat /tmp/pts_controller)"
ADMIN="$(cat /tmp/pts_admin)"
BMV2_CLI="$(cat /tmp/pts_bmv2_cli)"
SLICEMGR="$(cat /tmp/pts_slice_manager)"

ttyecho -n $MININET "./run.sh --commands hp4commands.txt --topo /home/kenway/Documents/hp4-ctrl/tests/t01/topo.txt"

ttyecho -n $CONTROLLER "./controller --debug"

# pause for keypress
echo "Next: create/provision 'jupiter' slice with lease to 'alpha' physical device"
read -n 1 -s

ttyecho -n $ADMIN "./client --debug --startup tests/t01/t01_admin admin"

echo "Next: create and configure L2 switch virtual device"
read -n 1 -s

ttyecho -n $SLICEMGR "./client --debug --startup tests/t01/t01_jupiter jupiter"

echo "Next: pairpings"
read -n 1 -s

ttyecho -n $MININET "source /home/kenway/Documents/hp4-ctrl/tests/t01/t01_pairpings"
