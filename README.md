# txt-agenda

`txt-agenda` is a script for keeping track of dates and deadlines scattered throughout a series of text files.  So far as I know, it is entirely POSIX compliant with the `-f` flag, and when that flag is omitted, the only additional dependency is [fzf]().  While this documentation is obviously incomplete, the script itself is functional.

## Syntax

The deadline and reminder syntax used by `txt-agenda` is taken from [Howm mode](http://howm.osdn.jp/) for Emacs, but the agenda behavior when using [fzf](https://github.com/junegunn/fzf) is closer to that of [Org-mode](https://orgmode.org/).

The format is as follows:

- Reminders `[YYYY-MM-DD]-` sink after the date
- Tasks `[YYYY-MM-DD]+` float after the date
- Deadlines `[YYYY-MM-DD]!` float before and after the date

As with Howm, repeated entries are achieved by entering multiple dates.

## Flags

 | `-f` | Report without `fzf`                                          | 
 | `-h` | Print help message                                            | 
 | `-y` | Output agenda items for the year centered on the current date | 


## progress

- [ ] Vim plugin for fzf.
- [ ] Setup man file (will need to look into roff).
    - see `man-pages(7)`
- [x] Determine whether an appended `q` command is likely to make Sed's print commands faster; see https://stackoverflow.com/questions/83329/how-can-i-extract-a-predetermined-range-of-lines-from-a-text-file-on-unix.
- [x] line output to something more sensible: date:line:filename:linenum; probably add a filename to the fzf preview; or maybe just change the preview layout to horizontal
- [X] allow arguments (getopt/getopts?)
- [X] Convert `$SORT_LINES` to a variable
- [X] Make `date` portable
    - [X] Set date properly when it's December or January
- [X] Preview context for datelines in fzf.
- [X] highlight matched date in fzf's preview window
- [X] test filtering with fzf now!
- [X] fix line display; ex: `[YYYY-MM-DD]+:LINUM:LINE:FILE`
- [X] preserve references to files while arranging the agenda

## Related Projects and Resources

- On the pattern of https://github.com/msprev/fzf-bibtex, using Go.
- https://github.com/bigH/git-fuzzy
- Howm: http://howm.osdn.jp/
- Ascetic bullet journaling: http://karolis.koncevicius.lt/posts/ascetic_bullet_journal/
