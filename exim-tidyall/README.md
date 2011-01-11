# exim-tidy-all

Enumerates all the hints databases in the Exim spool directory and executes
[exim_tidydb](http://www.exim.org/exim-html-current/doc/html/spec_html/ch50.html#SECThindatmai) for each one found.

## Usage

	exim-tidyall [OPTION]...

Run the command with `--help` argument or view the manual page to see available OPTIONS.

You should run this script periodically, say weekly:

	cd /etc/cron.weekly/
	ln -s /usr/sbin/exim-tidyall

Output is logged to a "tidydb" log in the directory specified by Exim log_file_path.
