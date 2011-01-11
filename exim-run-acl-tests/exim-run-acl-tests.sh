#!/bin/sh
#
# This script uses exim-test-session to test a series of Exim ACL checks
# listed in a file. Results can be shown in a grid, or two debug modes that
# let you investigate individual test cases.
#
# Usage: Run without any arguments to see usage
#
# Copyright (c) 2011 Lance Lovette. All rights reserved.
# Licensed under the BSD License.
# See the file LICENSE.txt for the full license text.
#
# Available from https://github.com/lovette/exim-tools

CMDPATH=$(readlink -f "$0")
CMDNAME=$(basename "$CMDPATH")
CMDDIR=$(dirname "$CMDPATH")
CMDARGS=$@

EXIMTOOL_VER="1.0.0"
EXIMTESTBIN="exim-test-session"

# Columns formatted for 115 character console
PRINTFSPEC115="%3s %-15.15s %-18.18s %-18.18s %-20.20s %-5.5s %b%-11.11s%b %b%-11.11s%b %b%-4.4s%b\n"

# You can find a list of color values at
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
TTYRED="\e[0;31m"
TTYGREEN="\e[0;32m"
TTYYELLOW="\e[0;33m"
TTYWHITE="\e[0;37m"
TTYRESET="\e[0m"

##########################################################################
# Functions

# Run a test case and show the result in a grid row
runtestcase_grid()
{
	local n=$1
	local hostip=$2
	local sender=$3
	local recipient=$4
	local helo=$5
	local datafile=$6
	local expected=$7
	local expectedcmd=""
	local actual=""
	local actualcmd=""
	local passfail="FAIL"
	local colorexpected=$TTYRED
	local coloractual=$TTYRED
	local colorpassfail=$TTYRED

	[ $# -ne 7 ] && echo "Test case $n: Unexpected number of test case arguments" && exit 1

	# datafile path is relative to test cases path if appropriate
	[[ "$datafile" =~ "^[[:alpha:]]" ]] && datafile="$TESTCASESDIR/$datafile"

	# Split expected result into RESULT/COMMAND if possible
	if [[ "$expected" =~ "^([[:alpha:]]+)/([[:alpha:]]+)$" ]]; then
		expected=${BASH_REMATCH[1]}
		expectedcmd=${BASH_REMATCH[2]}
	fi

	actual=$($EXIMTESTBIN "$hostip" "$sender" "$recipient" "$helo" "$datafile" 2>&1 | tail -n 1)
	[ $? -ne 0 ] && actual="CMDFAIL" && passfail="?"

	# Split actual result into RESULT/COMMAND if possible
	if [[ "$actual" =~ "^([[:alpha:]]+)/([[:alpha:]]+)$" ]]; then
		actual=${BASH_REMATCH[1]}
		actualcmd=${BASH_REMATCH[2]}
	fi

	# Compare result/command; expectedcmd is optional
	if [ "$actual" = "$expected" ]; then
		if [ -z "$expectedcmd" ] || [ "$actualcmd" = "$expectedcmd" ]; then
			passfail="PASS" && colorpassfail=$TTYGREEN
		fi
	fi

	case "$expected" in
		"Accept" ) colorexpected=$TTYGREEN;;
		"Reject" ) colorexpected=$TTYRED;;
		"Defer"  ) colorexpected=$TTYYELLOW;;
	esac

	case "$actual" in
		"Accept" ) coloractual=$TTYGREEN;;
		"Reject" ) coloractual=$TTYRED;;
		"Defer"  ) coloractual=$TTYYELLOW;;
	esac

	# Fixup column text
	[ -n "$expectedcmd" ] && expected="$expected/$expectedcmd"
	[ -n "$actualcmd" ] && actual="$actual/$actualcmd"
	datafilename=$(basename $datafile ".txt")

	printf "$PRINTFSPEC115" \
		$n \
		$hostip \
		$sender \
		$recipient \
		$helo \
		$datafilename \
		$colorexpected $expected $TTYRESET \
		$coloractual $actual $TTYRESET \
		$colorpassfail $passfail $TTYRESET
}

# Run a test case and show the SMTP transcript summary
runtestcase_summary()
{
	local n=$1
	local hostip=$2
	local sender=$3
	local recipient=$4
	local helo=$5
	local datafile=$6
	local expected=$7
	local opts=$8

	[ $# -ne 8 ] && echo "Test case $n: Unexpected number of test case arguments" && exit 1

	# datafile path is relative to test cases path if appropriate
	[[ "$datafile" =~ "^[[:alpha:]]" ]] && datafile="$TESTCASESDIR/$datafile"

	echo "Test case: $n"
	$EXIMTESTBIN $opts "$hostip" "$sender" "$recipient" "$helo" "$datafile" 2>&1 | sed "s/^/ /"
	[ $? -ne 0 ] && echo "$EXIMTESTBIN returned non-zero exit code" && exit 1
	echo
}

# Print version and exit
function version()
{
	echo "exim-run-acl-tests $EXIMTOOL_VER"
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
	echo "Run test cases in file TESTCASEFILE with specified output mode."
	echo
	echo "Test a series of Exim ACL checks listed in a file using exim-test-session."
	echo "Results can be shown in a grid, or two debug modes that let you"
	echo "investigate individual test cases."
	echo
	echo "Usage: exim-run-acl-tests [-h | --help | -V | --version]"
	echo "   or: exim-run-acl-tests TESTCASEFILE grid [TESTCASE_N]"
	echo "   or: exim-run-acl-tests TESTCASEFILE summary [TESTCASE_N]"
	echo "   or: exim-run-acl-tests TESTCASEFILE debug TESTCASE_N"
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

TESTCASESPATH=$1
TESTMODE=$2
TESTCASE_N_ARG=$3
TESTCASESDIR=""

if [ -z "$TESTMODE" ]; then
	echo "$CMDNAME: missing option -- an output mode must be specified"
	echo "Try '$CMDNAME --help' for more information."
	exit 1
fi

case "$TESTMODE" in
	"grid"    ) ;;
	"summary" ) ;;
	"debug"   ) ;;
	*         ) echo "$TESTMODE is not a valid test mode" && exit 1;;
esac

[ ! -f "$TESTCASESPATH" ] && echo "$TESTCASESPATH does not exist" && exit 1

# Convert test cases to full path
[ -n "$TESTCASESPATH" ] && TESTCASESPATH=$(readlink -f "$TESTCASESPATH")
TESTCASESDIR=$(dirname "$TESTCASESPATH")

# Read the test cases into an array
OLD_IFS="$IFS"
IFS=$'\n'
TESTCASES=( $(grep -v "^#" $TESTCASESPATH | grep -v "^[[:space:]]*$" | tr -d "\r") )
IFS="$OLD_IFS"

# We need to know when any pipe command fails, not just the last one
set -o pipefail

TESTCASE_N=0

# If specified, N must be a valid number
if [ -n "$TESTCASE_N_ARG" ]; then
	if [ $TESTCASE_N_ARG -lt 1 ] || [ $TESTCASE_N_ARG -gt ${#TESTCASES[@]} ]; then
		echo "TESTCASE_N must be between 1 and ${#TESTCASES[@]}"
		exit 1
	fi
fi

# Arrays are 0-based
TESTCASE_N=$TESTCASE_N_ARG
let TESTCASE_N--

##########################################################################
# DEBUG MODE

if [ "$TESTMODE" = "debug" ]; then
	# N is required for this mode
	if [ -z "$TESTCASE_N_ARG" ]; then
		echo "Usage: "$CMDNAME" debug TESTCASE_N"
		echo "TESTCASE_N must be specified and be between 1 and ${#TESTCASES[@]}"
		exit 1
	fi

	runtestcase_summary $TESTCASE_N_ARG ${TESTCASES[$TESTCASE_N]} "-v"

	exit 0
fi

##########################################################################
# TRANSCRIPT SUMMARY MODE

if [ "$TESTMODE" = "summary" ]; then
	if [ -z "$TESTCASE_N_ARG" ]; then
		TESTCASE_N=1
		for params in "${TESTCASES[@]}"
		do
			runtestcase_summary $TESTCASE_N $params ""
			let TESTCASE_N++
		done
	else
		runtestcase_summary $TESTCASE_N_ARG ${TESTCASES[$TESTCASE_N]} ""
	fi

	exit 0
fi

##########################################################################
# GRID MODE

printf "$PRINTFSPEC115" \
	N \
	HOST \
	SENDER \
	RECIPIENT \
	HELO \
	DATA \
	$TTYWHITE EXPECTED $TTYRESET \
	$TTYWHITE ACTUAL $TTYRESET \
	$TTYWHITE P/F $TTYRESET  

if [ -z "$TESTCASE_N_ARG" ]; then
	TESTCASE_N=1
	for params in "${TESTCASES[@]}"
	do
		runtestcase_grid $TESTCASE_N $params
		let TESTCASE_N++
	done
else
	runtestcase_grid $TESTCASE_N_ARG ${TESTCASES[$TESTCASE_N]}
fi

exit 0
