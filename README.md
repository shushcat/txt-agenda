# txt-agenda

`txt-agenda` is a POSIX compliant script for keeping track of `[YYYY-MM-DD]`-formatted dates in text files.
When called on one or more files, as in `txt-agenda FILES`, it returns lines from `FILES` that contain dates within one month of the current date.
The number of months to look into the past can be increased with the `-p` flag, and likewise for the future with `-f`.

<!-- ## Demo -->

<!-- ![](http://johnob.sdf.org/resources/txt-agenda_demo.gif) -->

## Command Line Options

| ----    | ----                                                | 
| `-p`    | Set the number of months to look into the past      | 
| `-f`    | Set the number of months to look into the future    | 
| `-h`    | Print help message                                  | 

## Credit & history

In commits 1ae5d0d1a1ef44c499ff3717b53cdd7df0530d68 and earlier, `txt-agenda` used a syntax similar to that of [Howm mode](http://howm.osdn.jp/), with `-`, `+`, and `!` suffixes to designate different kinds of reminders.
That functionality was removed since collecting dated tasks, for example, can easily be done by filtering lines with `grep`, as in `txt-agenda -p 4 -f 12 ~/your_notes/*.md | grep "TODO\|\[ \]"`, which will return all lines that contain dates no more than 4 months in the past, no more than 12 months in the future, and which contain either the string `TODO` or a Markdown checkbox.

Inspiration for this project came from extensive use of [Org-mode](https://orgmode.org/) and a desire to for a faster, editor-independent `org-agenda`.
