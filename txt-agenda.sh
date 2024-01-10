#!/bin/sh

set -eu
umask u=rwx,og=

strip_leading_zeroes() {
	n=$1
	while [ "$n" != "${n#0}" ] ;do n=${n#0};done
	echo "$n"
}

YEAR=$(strip_leading_zeroes "$(date "+%Y")")
MONTH=$(strip_leading_zeroes "$(date "+%m")")
DAY=$(strip_leading_zeroes "$(date "+%d")")

usage() {
	cat 1>&2 <<-EOF
	${1:+Error: ${1}}
	USAGE:  ${0##*/} [-fhy] FILES

	Display an agenda based on [YYYY-MM-DD] formated dates in FILES.

	Flags:
	-h	Show this message.
	-y	Output a yearlong agenda, centered on today.

	Some day, you will look to txt-agenda(1) for surehanded guidance in all things.

	EOF
	exit ${1:+1}
}

format_date() {
	y=$1
	m=$2
	d=$3
	printf "%04d-%02d-%02d" "$y" "$m" "$d"
}

set_past_sentinel() {
        BYEAR=${YEAR}
        BMONTH=${MONTH}
	for i in `seq $1`; do
		if [ "${BMONTH}" -eq 1 ]; then
			BMONTH=12
			BYEAR=$((BYEAR - 1))
		else
			BMONTH=$((BMONTH - 1))
		fi
	done
        PAST_SENTINEL="$(format_date "${BYEAR}" "${BMONTH}" "${DAY}")"
}

set_future_sentinel() {
        FYEAR=${YEAR}
        FMONTH=${MONTH}
	for i in `seq $1`; do
		if [ "${FMONTH}" -eq 12 ]; then
			FMONTH=01
			FYEAR=$((FYEAR + 1))
		else
			FMONTH=$((FMONTH + 1))
		fi
	done
	FUTURE_SENTINEL="$(format_date "${FYEAR}" "${FMONTH}" "${DAY}")"
	echo $FUTURE_SENTINEL
}

set_month_range() {
        BYEAR=${YEAR}
        FYEAR=${YEAR}
	BMONTH=$((MONTH - 1))
	FMONTH=$((MONTH + 1))
        # Account for January and December.
        if [ "${MONTH}" -eq 1 ]; then
                BMONTH=12
                BYEAR=$((YEAR - 1))
        elif [ "${MONTH}" -eq 12 ]; then
                FMONTH=01
                FYEAR=$((YEAR + 1))
        fi
        PAST_SENTINEL="$(format_date "${BYEAR}" "${BMONTH}" "${DAY}")"
	PRESENT_SENTINEL="$(format_date "${YEAR}" "${MONTH}" "$((DAY + 1))")"
	FUTURE_SENTINEL="$(format_date "${FYEAR}" "${FMONTH}" "${DAY}")"
}

set_year_range() {
        BYEAR=$((YEAR - 1))
        FYEAR=$((YEAR + 1))
        PAST_SENTINEL="$(format_date "${BYEAR}" "${MONTH}" "${DAY}")"
	PRESENT_SENTINEL="$(format_date "${YEAR}" "${MONTH}" "$((DAY + 1))")"
	FUTURE_SENTINEL="$(format_date "${FYEAR}" "${MONTH}" "${DAY}")"
}

dated_lines() {
	DATED_LINES=$(grep -nH '\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\]' "$@" || true)
	DATED_LINES=$(echo "${DATED_LINES}" | \
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
				gsub(/\][^\[]*/, "]:", line_dates)
				gsub(/\][^\[]*\[/, "]:[", line_dates)
				split(line_dates, line_date_ary)
				for (date_str in line_date_ary) {
					if (line_date_ary[date_str] ~ \
						/\[[0-9]{4}-[0-9][0-9]-[0-9][0-9]\]/) {
						gsub(/ /, "", line_date_ary[date_str])
						print line_date_ary[date_str] ":" $1 ":" $2 ":" line_text
					}
				}
		}')
        DATED_LINES="${DATED_LINES}"$(echo; echo "[${PAST_SENTINEL}]";
                echo "[${PRESENT_SENTINEL}]";
                echo "[${FUTURE_SENTINEL}]");
}

sorted_lines() {
        SORT_LINES=$(echo "$DATED_LINES" | sort -d);
}

lines_in_range() {
        beg=$(echo "${SORT_LINES}" | grep -m 1 -n "^\\[${PAST_SENTINEL}\\]" | \
                sed 's/:\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\].*$//')
        end=$(echo "${SORT_LINES}" | grep -m 1 -n "^\\[${FUTURE_SENTINEL}\\]" | \
                sed 's/:\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\].*$//')
        LINES_IN_RANGE=$(echo "${SORT_LINES}" | sed -n "${beg},${end}p" | \
                (grep '^\[[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\]:' || true))
}

report() {
	echo "${LINES_IN_RANGE}" | sed '/^ *$/d'
        exit
}

[ ${#} -eq 0 ] &&
        usage 'too few arguments'
while getopts "p:f:h" OPTION; do
        case ${OPTION} in
	p)
		set_past_sentinel $2
		;;
	f)
		set_future_sentinel $2
		;;
        h)
                usage
                ;;
        *)
                usage 'invalid option'
                ;;
        esac
done
shift $((OPTIND - 1))

exit
dated_lines "$@"
sorted_lines
lines_in_range
report
