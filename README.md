# txt-agenda

`txt-agenda` is a POXIX compliant script for keeping track of dates and deadlines kept in text files.
When called on one or more files, as in `txt-agenda FILES`, it returns a list sorted by date of all lines in `FILES` containing dates in `[YYYY-MM-DD]` format within a month of the current date.
The `-p` and `-f` flags can be used to increase the number of past and future months, respectively, included in the output.

<!-- ## Demo -->

<!-- ![](http://johnob.sdf.org/resources/txt-agenda_demo.gif) -->

## Command Line Options

| `-p`    | Set the number of months to look into the past      | 
| `-f`    | Set the number of months to look into the future    | 
| `-h`    | Print help message                                  | 

## Credit & history

Prior to commit ____qq, `txt-agenda` used a syntax similar to that of [Howm mode](http://howm.osdn.jp/), with `-`, `+`, and `!` suffixes to designate different kinds of reminders.
If you would like to use code from earlier versions of `txt-agenda`, including `sed` commands for highlighting dates on a given line, see commit ____qq.

Inspiration for this project came from extensive use of [Org-mode](https://orgmode.org/) and a desire to for a faster, editor-independent `org-agenda`.
