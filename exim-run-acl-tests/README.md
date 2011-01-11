# exim-run-acl-tests

Test a series of Exim ACL checks listed in a file using exim-test-session.
Results can be shown in a grid, or two debug modes that let you investigate
individual test cases.

## Usage

	exim-run-acl-tests TESTCASEFILE MODE [TESTCASE_N]

Run the command with `--help` argument or view the manual page to see available OPTIONS.

## Test Cases

Each line in file TESTCASES must contain 6 columns, each separated by a space:

	HOSTIP SENDER RECIPIENT HELO DATAFILE EXPECTED

* HOSTIP - IP address of remote host
* SENDER - Email address of sender, or '-' to simulate an empty sender (bounce)
* RECIPIENT - Email address of recipient
* HELO - HELO text to use instead of HOSTIP; '-' if default
* DATAFILE - Path of file to use in DATA command; '-' if none
* EXPECTED - The expected result: Accept, Reject, Defer.
  If you want to be more specific for Reject and Defer, you can
  include the command that should elicit
  the result as: EXPECTED/COMMAND.
  Valid commands are: HELO, MAIL, RCPT, DATA

See the usage of exim-test-session for more details on the first 5 columns.

Blank lines and lines that begin with # are ignored.

## Example

<pre>
[~]$ exim-run-acl-tests sampletests.txt grid
N HOST            SENDER               RECIPIENT            HELO                    EXPECTED    ACTUAL      P/F
1 127.0.0.1       spammer@remotehost.c test@somewhere.org   localhost               <span style="color:red">Reject/RCPT</span> <span style="color:red">Reject/RCPT</span> <span style="color:green">PASS</span>
2 127.0.0.1       test@yourdomain.com  test@somewhere.org   localhost               <span style="color:red">Reject</span>      <span style="color:red">Reject/RCPT</span> <span style="color:green">PASS</span>
3 127.0.0.1       test@yourdomain.com  test@somewhere.org   localhost               <span style="color:green">Accept</span>      <span style="color:red">Reject/RCPT</span> <span style="color:red">FAIL</span>
</pre>
