#!/bin/bash

cd /home/kenway/Documents/src/hp4
gnome-terminal  --geometry=80x20+0+0 --command="bash -c \"tty > /tmp/pts_mininet; exec bash\"" &
sleep 0.2
cd /home/kenway/Documents/hp4-ctrl
gnome-terminal  --geometry=90x30+800+0 --command="bash -c \"tty > /tmp/pts_controller; exec bash\"" &
sleep 0.2
gnome-terminal  --geometry=80x20+0+415 --command="bash -c \"tty > /tmp/pts_admin; exec bash\"" &
sleep 0.2
cd /home/kenway/Documents/src/hp4
gnome-terminal  --geometry=80x20+0+805 --command="bash -c \"tty > /tmp/pts_bmv2_cli; exec bash\"" &
sleep 0.2
cd /home/kenway/Documents/hp4-ctrl
gnome-terminal  --command="bash -c \"tty > /tmp/pts_slice_manager; exec bash\"" &
