#!/bin/sh

set -eu
umask u=rwx,og=

strip_leading_zeroes() {
	n=$1
	while [ "$n" != "${n#0}" ] ;do n=${n#0};done
	echo "$n"
}

format_date() {
	y=$1
	m=$2
	d=$3
	printf "%04d-%02d-%02d" "$y" "$m" "$d"
}

YEAR=$(strip_leading_zeroes "$(date "+%Y")")
MONTH=$(strip_leading_zeroes "$(date "+%m")")
DAY=$(strip_leading_zeroes "$(date "+%d")")
PRESENT_SENTINEL="$(format_date "${YEAR}" "${MONTH}" "$((DAY + 1))")"

usage() {
	cat 1>&2 <<-EOF
	${1:+Error: ${1}}
	USAGE:  ${0##*/} [-p NUM] [-f NUM] [-h] FILES

	Print a sorted list of lines in FILES that contain [YYYY-MM-DD]
	formatted dates.

	Flags:
	-p NUM	Include dates up to NUM months in the past.
	-f NUM	Include dates up to NUM months in the future.
	-h	Show this message.

	Some day, you will look to txt-agenda(1) for surehanded guidance in all things.

	EOF
	exit ${1:+1}
}
 
is_int() {
	if [ "$(($1 + 0))" -eq 0 ]; then
		return 1
	else
		return 0
	fi
}

is_pos_int() {
	if $(is_int "$1") && [ "${OPTARG}" -gt 0 ]; then
		return 0
	else
		return 1
	fi
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

# Look one month into the past and one month into the future by default.
set_past_sentinel 1
set_future_sentinel 1

[ ${#} -eq 0 ] &&
        usage 'too few arguments'
while getopts "p:f:h" OPTION; do
        case ${OPTION} in
	p)
		is_pos_int "${OPTARG}" || usage "-p requires a positive integer"
		set_past_sentinel ${OPTARG}
		;;
	f)
		is_pos_int "${OPTARG}" || usage "-f requires a positive integer"
		set_future_sentinel ${OPTARG}
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

dated_lines "$@"
sorted_lines
lines_in_range
report
