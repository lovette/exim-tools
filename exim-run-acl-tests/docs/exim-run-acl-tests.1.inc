[OUTPUT MODES]
.TP
grid
Display each test case as a row in a grid;
optionally limit run to test case N
.TP
summary
Display a transcript summary;
optionally limit run to test case N
.TP
debug
Display a debug debug for test case N

[TEST CASES]
.PP
Each line in file TESTCASEFILE must contain 6 columns,
each separated by a space.
.IP
HOSTIP SENDER RECIPIENT HELO DATAFILE EXPECTED
.PP
HOSTIP, SENDER, RECIPIENT, HELO, DATAFILE:
.IP
See the usage of exim\-test\-session for details
.PP
EXPECTED:
.IP
The expected result: Accept, Reject, Defer.
For Reject and Defer, you can also include the command that
should elicit the result as: EXPECTED/COMMAND.
Valid commands are: HELO, MAIL, RCPT, DATA.
