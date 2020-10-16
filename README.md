# txt-agenda

Txt-agenda is a script for keeping track of dates and deadlines kept in text files.  It's core logic is POSIX compliant, but it opportunistically uses [fzf](https://github.com/junegunn/fzf) to filter, display, and jump to lines.

## Demo

Coming soon....

![](http://johnob.sdf.org/resources/txt-agenda_demo.gif)

## Usage

When invoked as `txt-agenda FILES`, Txt-agenda generates a chronological list of the dates found in the text files `FILES`.  In order for a date to be recognized by Txt-agenda, it must be in one of three forms:

- Reminders `[YYYY-MM-DD]-` sink after their date,
- Tasks `[YYYY-MM-DD]+` float after their date, and
- Deadlines `[YYYY-MM-DD]!` float before and after their date.

What that means is that a line containing the date `[2077-10-16]-` will not appear until October 16th (of 2077), then will sink as time passes until it falls outside the agenda span.  In contrast to that behavior, a line containing `[2077-10-16]+` will float near the top of the agenda once the 16th arrives, and a line containing `[2077-10-16]!` will appear at the top of the agenda several weeks before the 16th, then will float afterwards.

 | ---  | ---                                                           | 
 | `-f` | Report without `fzf`                                          | 
 | `-h` | Print help message                                            | 
 | `-y` | Output agenda items for the year centered on the current date | 

## Progress

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

## Credit

The deadline and reminder syntax used by `txt-agenda` is taken from [Howm mode](http://howm.osdn.jp/) for Emacs, but the agenda behavior when using [fzf](https://github.com/junegunn/fzf) is closer to that of [Org-mode](https://orgmode.org/).
