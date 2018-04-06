#!/usr/bin/env bash

# Nagios-cli wrapper to quickly disable and enable notifcations for specific sites
# nothing fancy here move along, this was stripped out of a more complex wrapper I use locally

/usr/local/bin/nagios-cli --host localhost --port 4599 "$1"-notifications "$2" --recursive
