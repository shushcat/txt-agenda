#!/bin/sh

set -eu
umask u=rwx,og=

if command -v fzf >/dev/null; then 
        RPTCMD=fzf_report
else
        RPTCMD=report
fi
RNGCMD=set_month_range

usage() {
	cat 1>&2 <<-EOF
	${1:+Error: ${1}}
	USAGE:  ${0##*/} [-fhy] FILES

	Display an agenda based on [YYYY-MM-DD] formated dates in FILES.

	Syntax:
	[YYYY-MM-DD]-	is a sinking reminder,
	[YYYY-MM-DD]+	is a floating task, and
	[YYYY-MM-DD]!	is a looming deadline.
	
	Flags: 
	-f	Suppress fzf on systems where it is present.
	-h	Show this message.
	-y	Output a yearlong agenda, centered on today.

	Some day, you will look to txt-agenda(1) for surehanded guidance in all things.

	EOF
	exit ${1:+1}
}

set_date_sentinels() {
	YEAR=$(strip_leading_zeroes $(date "+%Y"))
	MONTH=$(strip_leading_zeroes $(date "+%m"))
	DAY=$(strip_leading_zeroes $(date "+%d"))
        ${RNGCMD}
}

strip_leading_zeroes() {
	n=$1
	while [ "$n" != "${n#0}" ] ;do n=${n#0};done
	echo $n
}

format_date() {
	y=$1
	m=$2
	d=$3
	printf "%04d-%02d-%02d" $y $m $d
}

set_month_range() {
        BYEAR=${YEAR}
        FYEAR=${YEAR}
	BMONTH=$(($MONTH - 1))
	FMONTH=$(($MONTH + 1))
        # Account for January and December.
        if [ "${MONTH}" -eq 1 ]; then
                BMONTH=12
                BYEAR=$((${YEAR} - 1))
        elif [ "${MONTH}" -eq 12 ]; then
                FMONTH=01
                FYEAR=$((${YEAR} + 1))
        fi
        PAST_SENTINEL="$(format_date ${BYEAR} ${BMONTH} ${DAY})"
	PRESENT_SENTINEL="$(format_date ${YEAR} ${MONTH} $(($DAY + 1)))"
	FUTURE_SENTINEL="$(format_date ${FYEAR} ${FMONTH} ${DAY})"
}

set_year_range() {
        BYEAR=$((${YEAR} - 1))
        FYEAR=$((${YEAR} + 1))
        PAST_SENTINEL="$(format_date ${BYEAR} ${MONTH} ${DAY})"
	PRESENT_SENTINEL="$(format_date ${YEAR} ${MONTH} $(($DAY + 1)))"
	FUTURE_SENTINEL="$(format_date ${FYEAR} ${MONTH} ${DAY})"
}

get_sort_lines() {
	DATE_LINES=$(for file in "${FILES}"; do
		grep -nH '\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\][\+\!\-]' $file; 
	done)
	DATE_LINES=$(echo "${DATE_LINES}" | \
	# Split lines with Awk such that every date on a line is output as a
	# new instance of that line headed by that date in [YYYY-MM-DD] format.
		awk '
			BEGIN {
				FS=":"
			} 
			{
				line_text=substr($0, index($0,$3))
				sub(/^\s*/, "", line_text)
				line_dates=line_text
				sub(/^[^\[]*\[/,"[", line_dates)
				gsub(/\]\-[^\[]*/, "]-:", line_dates)
				gsub(/\]\+[^\[]*/, "]+:", line_dates)
				gsub(/\]![^\[]*/, "]!:", line_dates)
				gsub(/\][^\[\-\+!]*\[/, "]:[", line_dates)
				split(line_dates, line_date_ary)
				for (date_str in line_date_ary) {
					if (line_date_ary[date_str] ~ \
						/\[[0-9]{4}-[0-9][0-9]-[0-9][0-9]\][\-\+!]/) {
						gsub(/ /, "", line_date_ary[date_str])
						print line_date_ary[date_str] ":" $1 ":" $2 ":" line_text
					}
				}
		}')
        DATE_LINES="${DATE_LINES}"$(echo; echo "[${PAST_SENTINEL}]"; 
                echo "[${PRESENT_SENTINEL}]"; 
                echo "[${FUTURE_SENTINEL}]");
        SORT_LINES=$(echo "$DATE_LINES" | sort -d);
}

get_sink_lines() {
        beg=$(echo "${SORT_LINES}" | grep -m 1 -n "^\[${PAST_SENTINEL}\]" | \
                sed 's/:\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\].*$//')
        end=$(echo "${SORT_LINES}" | grep -m 1 -n "^\[${PRESENT_SENTINEL}\]" | \
                sed 's/:\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\].*$//')
        SINK_LINES=$(echo "${SORT_LINES}" | sed -n "${beg},${end}p" | \
                (grep '^\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\][\-]' || true))
}

get_task_lines() {
        TASK_LINES=$(echo "${SORT_LINES}" | sed -n "1,${end}p" | \
                (grep '^\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\][\+]' || true))
 }

get_dead_lines() {
        end=$(echo "${SORT_LINES}" | grep -m 1 -n "^\[${FUTURE_SENTINEL}\]" | \
                sed 's/:\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\].*$//')
        DEAD_LINES=$(echo "${SORT_LINES}" | sed -n "1,${end}p" | \
                (grep '^\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\][\!]' || true))
}

report() {
        { echo "${SINK_LINES}";
                echo "${TASK_LINES}";
                echo "${DEAD_LINES}"; } | sed '/^ *$/d'
        exit
}

fzf_preview() {
	beg=$(echo "$1" | cut -d':' -f3)
	date=$(echo "$1" | cut -d':' -f1 | sed "s/^\[\([0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\)\]./\1/")
	file=$(echo "$1" | cut -d':' -f2) 
	marker=$(echo "$1" | cut -d':' -f1 | sed "s/^\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\]\(.\)/\1/")
	if [ $beg -lt 4 ]; then
		hln=$beg
		beg=1
	else
		hln=4
		beg=$(($beg-3))
	fi
	sed -n -e "$beg,+20p" "$file" | \
		sed -e ${hln}s/[[]$date[]]$marker/`printf "\e[7m"`\[$date\]$marker`printf "\e[0m"`/g
	exit
}

fzf_report() {
	selected=$(report | fzf --tac --no-sort +s --preview-window=up:wrap --preview="$0 -p {}")
        selected_file_name=$(echo "${selected}" | cut -d':' -f2)
        selected_line_num=$(echo "${selected}" | cut -d':' -f3)
        exec "echo" "$selected_line_num" "$selected_file_name"
}

[ ${#} -eq 0 ] &&
        usage 'too few arguments'
while getopts "fhpy" OPTION; do
        case ${OPTION} in
        f)
                RPTCMD=report
                ;;
        h)
                usage
                ;;
	p)
		fzf_preview "$2"
		;;
        y)
                RNGCMD=set_year_range
                ;;
        *)
                usage 'invalid option'
                ;;
        esac
done
shift $((OPTIND - 1))

FILES=$(for file in "$@"; do echo $file; done)

set_date_sentinels
get_sort_lines
get_sink_lines
get_task_lines
get_dead_lines
${RPTCMD}
