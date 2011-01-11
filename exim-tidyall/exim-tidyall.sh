#!/bin/bash
#
# This script enumerates all the hints databases in the spool directory and 
# executes exim_tidydb for each one found. Output is logged to a "tidydb" log
# in the directory specified by Exim log_file_path.
# You should run this script periodically, say in cron.weekly.
#
# Usage: exim-tidyall
#
# Copyright (c) 2011 Lance Lovette. All rights reserved.
# Licensed under the BSD License.
# See the file LICENSE.txt for the full license text.
#
# Available from https://github.com/lovette/exim-tools

EXIMBIN=/usr/sbin/exim
EXIMTIDYDBBIN=/usr/sbin/exim_tidydb
EXIMTOOL_VER="1.0.0"

##########################################################################
# Functions

# Print version and exit
function version()
{
	echo "exim-tidyall $EXIMTOOL_VER"
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
	echo "Enumerates all the hints databases in the Exim spool directory"
	echo "and executes exim_tidydb for each one found."
	echo
	echo "Usage: exim-tidyall [OPTION]..."
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

spooldir=$($EXIMBIN -bP spool_directory 2>&1 | grep "=" | cut -d= -f2 | tr -d " ")
logfilepathspec=$($EXIMBIN -bP log_file_path 2>&1 | grep "=" | cut -d= -f2 | tr -d " ")
tidylogpath=$(printf "$logfilepathspec" "tidydb")
logdir=$(dirname "$tidylogpath")
logtod=$(date +"%F %T")

[ -z "$spooldir" ] && echo "Cannot determine Exim spool directory path (exim -bP spool_directory)" && exit 1
[ ! -d "$spooldir" ] && echo "Exim spool directory does not exist ($spooldir)" && exit 1
[ ! -r "$spooldir" ] && echo "Exim spool directory is not readable ($spooldir)" && exit 1

[ -z "$logfilepathspec" ] && echo "Cannot determine Exim log directory path (exim -bP log_file_path)" && exit 1

[ ! -d "$logdir" ] && echo "Exim log directory does not exist ($logdir)" && exit 1
[ ! -w "$logdir" ] && echo "Exim log directory is not writable ($logdir)" && exit 1

if [ ! -f "$tidylogpath" ]; then
	touch "$tidylogpath" || exit 1
	chmod 640 "$tidylogpath" || exit 1
fi

for dbpath in $spooldir/db/*
do
	dbname=$(basename $dbpath)
	[ ! -f "$dbpath" ] && continue
	[[ "$dbname" =~ .lockfile$ ]] && continue
	$EXIMTIDYDBBIN -t 7d "$spooldir" "$dbname" 2>&1 | sed "s/^/$logtod /" >> "$tidylogpath"
done
