# txt-agenda

`txt-agenda` is a POSIX compliant script that searches text files to find and print lines containing `[YYYY-MM-DD]`-formatted dates.
Lines are sorted by date, but each line is prefixed with the file name and line number where it was found.
When called on one or more files, as in `txt-agenda FILES`, it returns lines from `FILES` that contain dates within one month of the current date.
The date range can be inclusively extended with the `-p` (for **p**ast) and `-f` (for **f**uture) flags, so `txt-agenda -p 1 -f 4 FILES` will return all lines from `FILES` that contain dates that are no more that 1 month in the past and no more than 10 months in the future.

<!-- ## Demo -->

<!-- ![](http://johnob.sdf.org/resources/txt-agenda_demo.gif) -->

## Command Line Options

| Flag    |                                                     | 
| ----    | ----                                                | 
| `-p`    | Set the number of months to look into the past      | 
| `-f`    | Set the number of months to look into the future    | 
| `-h`    | Print help message                                  | 

## Credit & history

In commit [1ae5d0d](1ae5d0d1a1ef44c499ff3717b53cdd7df0530d68) and earlier, `txt-agenda` used a syntax similar to that of [Howm mode](http://howm.osdn.jp/), with `-`, `+`, and `!` suffixes to designate different kinds of reminders.
That functionality was removed since collecting dated tasks, for example, can easily be done by filtering lines returned by `txt-agenda` with `grep`, as in `txt-agenda -p 4 -f 12 ~/your_notes/*.md | grep "TODO\|\[ \]"`, which will return all lines that contain dates no more than 4 months in the past, no more than 12 months in the future, and which contain either the string `TODO` or a Markdown checkbox.

`txt-agenda` was motivated by the desire for a simpler, faster, pipeline-composable, and editor-independent version of (a subset of) [Org-mode](https://orgmode.org/)'s `org-agenda`.
