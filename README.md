# txt-agenda

`txt-agenda` is a script for keeping track of dates and deadlines scattered throughout a series of text files.  So far as I know, it is entirely POSIX compliant with the `-f` flag, and when that flag is omitted, the only additional dependency is [fzf]().

# desired behavior

Deadline and reminder syntax like that used by Howm mode in Emacs.
See https://www.emacswiki.org/emacs/HowmMode.
The format is as follows:

- Reminders `[YYYY-MM-DD]-` sink after the date
- Tasks `[YYYY-MM-DD]+` float after the date
- Deadlines `[YYYY-MM-DD]!` float before and after the date

A simpler alternative may be desirable.  What about
- `[YYYY-MM-DD]` for sinking reminders,
- `.[YYYY-MM-DD]` for floating tasks, and
- `![YYYY-MM-DD]` for floating deadlines?

## repeating events

How should these work?  Should they even be allowed?  What is the desired behavior?

Format                  Action
-------                 -----------------------------
[2020-06-12 +1m]-       Advance date by one month.
[2020-06-12 ++1m]-      Advance the date by one month at a time until it is in the future.
[2020-06-12 .+1m]-      Advance the date by one month from today.

[2020-06-12]-1m
[2020-06-12]-1y

What about a syntax that included ranges in it?

[2020-[7-12]-8] for the 8th of the months from July through December.

### Remind

The syntax for [Remind](https://dianne.skoll.ca/projects/remind/) command is very flexible, but its complex syntax would obscure the ISO dates.

### Org Mode

The "repeater" markers from [Org Mode](https://orgmode.org/manual/Repeated-tasks.html#Repeated-tasks) are promising.  The syntax has the form `[.+]?\+\d[ymd]` so that, eg, "+1m"  and ".+42y" are both valid markers.

### Howm

The author of Howm recommends^[https://www.emacswiki.org/emacs/HowmMode and http://howm.osdn.jp/README.html] that one enter copies of an event to make it repeat, but I think that is bad.  Better to use wildcards, as is done with Cron.  Then if one wants to, say, have an event repeat every year on the first of August, e would write [*-08-01]?, where '?' represents the chosen suffix.

# resources

- On the pattern of https://github.com/msprev/fzf-bibtex, using Go.
- https://github.com/bigH/git-fuzzy
- Howm: http://howm.osdn.jp/
- Ascetic bullet journaling: http://karolis.koncevicius.lt/posts/ascetic_bullet_journal/

# Display different date ranges
prospective flags
    -f (forward), -b (back)
    -y for year view?  -w for week and -m for month (default)

# progress

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
