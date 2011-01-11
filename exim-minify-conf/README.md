# exim-minify-conf

Minify an Exim configuration file by stripping comments, blank lines, and processing includes.

## Usage

	exim-minify-conf [OPTION]... INFILE [OUTFILE|-]

Run the command with `--help` argument or view the manual page to see available OPTIONS.

## Why

Liberal comments in Exim configuration files are crucial. But there's no reason to make
the daemon read all those comments every single time it runs. In addition, sometimes
it's easier to digest a configuration file if it's smaller. Running this tool
on the default exim.conf reduces the size from 35K to 2.5K.

## Requirements

* [M4](http://www.gnu.org/software/m4/) must be installed to process includes
