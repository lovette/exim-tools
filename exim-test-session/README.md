# exim-test-session

Simulates an SMTP session from a remote host using `exim -bhc`.

It's purpose is similar to that provided by the [exim_checkaccess](http://www.exim.org/exim-html-current/doc/html/spec_html/ch50.html#SECTcheckaccess)
tool distributed with Exim.

In addition to showing whether the message is accepted, rejected, or deferred
as exim_checkaccess does, this tool has these features:

* SMTP transcript is color highlighted for easy interpretation
* HELO text can be set
* LOG messages are shown
* add_header calls are shown
* DATA ACLs can be checked

## Usage

	exim-test-session [OPTION]... HOSTIP SENDER RECIPIENT [HELO|-] [DATAFILE|-]

* HOSTIP - IP address of remote host
* SENDER - Email address of sender, or '-' to simulate an empty sender (bounce)
* RECIPIENT - Email address of recipient
* HELO - HELO text to use instead of HOSTIP; '-' if default
* DATAFILE - Path of file to use as content of DATA command; '-' if none

Run the command with `--help` argument or view the manual page to see available OPTIONS.

## Example

### Routing accepted

<pre>
[~]$ exim-test-session 127.0.0.1 user@yourdomain.com recipient@somewhere.org
127.0.0.1 [127.0.0.1] <user@yourdomain.com> to <recipient@somewhere.org>
<div style="background:white;color:blue;margin:0px">220 mail.yourdomain.com ESMTP MTA Wed, 01 Dec 2010 21:24:35 +0000
250 mail.yourdomain.com Hello localhost.localdomain [127.0.0.1]
250 OK
250 Accepted
221 mail.yourdomain.com closing connection</div>Accept
</pre>

### Relay not permitted

<pre>
[~]$ exim-test-session 127.0.0.1 bogus@domain.com recipient@somewhere.org
127.0.0.1 [127.0.0.1] <bogus@domain.com> to <recipient@somewhere.org>
<div style="background:white;color:blue;margin:0px">220 mail.yourdomain.com ESMTP MTA Wed, 01 Dec 2010 21:24:35 +0000
250 mail.yourdomain.com Hello localhost.localdomain [127.0.0.1]
250 OK
550 Relay not permitted
221 mail.yourdomain.com closing connection</div><span style="color:red">LOG: H=localhost.localdomain (127.0.0.1) [127.0.0.1] F=<bogus@domain.com> rejected RCPT <recipient@somewhere.org>: Relay not permitted</span>
Reject/RCPT
</pre>
