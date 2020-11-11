# txt-agenda

Txt-agenda is a script for keeping track of dates and deadlines kept in text files.  It's core logic is POSIX compliant, but it opportunistically uses [fzf](https://github.com/junegunn/fzf) to filter, display, and jump to lines.  If fzf is not installed, or if it is suppressed with the `-f` flag, lines containing agenda items are printed on standard out.

<!-- ## Demo -->

<!-- ![](http://johnob.sdf.org/resources/txt-agenda_demo.gif) -->

## Usage

When invoked as `txt-agenda FILES`, Txt-agenda generates a chronological list of the dates found in the text files `FILES`.  In order for a date to be recognized by Txt-agenda, it must be in one of three forms:

- Reminders `[YYYY-MM-DD]-` sink after their date,
- Tasks `[YYYY-MM-DD]+` float after their date, and
- Deadlines `[YYYY-MM-DD]!` float before and after their date.

What that means is that a line containing the date `[2077-10-16]-` will not appear on the agenda until October 16th (of 2077), then will sink daily until it falls outside the agenda span.  In contrast, a line containing either `[2077-10-16]+` or `[2077-10-16]!` will remain on the agenda after the 16th, and the deadline (`[2077-10-16!`) will appear at the top of the agenda several weeks beforehand.

The basic form of the output from `txt-agenda` is chronological within datestamp types, with tasks after reminders and deadlines after tasks.

    [2077-11-17]-:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-17]-.
    [2077-11-18]-:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-18]-.
    [2077-11-17]+:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-17]-.
    [2077-11-18]+:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-18]-.
    [2077-11-17]!:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-17]!.
    [2077-11-18]!:FILE_PATH:LINE_NUM:The line containing the datestamp [2077-11-18]!.

### Command Line Options

 | Flag | Behavior                                                      | 
 | ---  | ---                                                           | 
 | `-f` | Report without `fzf`                                          | 
 | `-h` | Print help message                                            | 
 | `-y` | Output agenda items for the year centered on the current date | 

## Credit

The deadline and reminder syntax used by `txt-agenda` is taken from [Howm mode](http://howm.osdn.jp/) for Emacs, but the agenda behavior when using [fzf](https://github.com/junegunn/fzf) is closer to that of [Org-mode](https://orgmode.org/).
