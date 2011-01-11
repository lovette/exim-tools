#!/bin/bash
#
# This script sends a HUP signal to the running Exim daemon, if any
#
# Usage: exim-hup
#
# Copyright (c) 2011 Lance Lovette. All rights reserved.
# Licensed under the BSD License.
# See the file LICENSE.txt for the full license text.
#
# Available from https://github.com/lovette/exim-tools

EXIMBIN=/usr/sbin/exim
EXIMTOOL_VER="1.0.0"

##########################################################################
# Functions

# Print version and exit
function version()
{
	echo "exim-hup $EXIMTOOL_VER"
	echo
	echo "Copyright (C) 2011 Lance Lovette"
	echo "Licensed under the BSD License."
	echo "See the distribution file LICENSE.txt for the full license text."
	echo
	echo "Written by Lance Lovette <https://github.com/lovette>"

	exit 0
}

# Print usage and exit
function usage()
{
	echo "Sends a HUP signal to the running Exim daemon, if any."
	echo
	echo "Usage: exim-hup [OPTION]..."
	echo
	echo "Options:"
	echo "  -h, --help     Show this help and exit"
	echo "  -V, --version  Print version and exit"
	echo
	echo "Report bugs to <https://github.com/lovette/exim-tools/issues>"

	exit 0
}

##########################################################################
# Main

# Check for usage longopts
case "$1" in
	"--help"    ) usage;;
	"--version" ) version;;
esac

# Parse command line options
while getopts "hV" opt
do
	case $opt in
	h  ) usage;;
	V  ) version;;
	\? ) echo "Try '$CMDNAME --help' for more information."; exit 1;;
	esac
done

pidfile=$($EXIMBIN -bP pid_file_path 2>&1 | grep "=" | cut -d= -f2 | tr -d " ")

[ -z "$pidfile" ] && echo "Cannot determine Exim pidfile path (exim -bP pid_file_path)" && exit 1

if [ ! -f "$pidfile" ]; then
	echo "Exim is not running"
	exit 0
fi

pidval=$(cat "$pidfile")
echo "Sending HUP to running Exim daemon [PID:$pidval]"
kill -HUP $pidval
