#!/bin/bash

#==============================================================================
#
# show_from_log.sh - Show focus precision tool measurement data from given
#                    log file
# Copyright (C) 2021  Ljubomir Kurij
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#==============================================================================


#==============================================================================
#
# History
# ----------------------------------------------------------------------------
#
# 2021-09-23 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
# * Created
#
#==============================================================================


#==============================================================================
#
# References
# ----------------------------------------------------------------------------
#
#
#
#==============================================================================


#==============================================================================
#
# Functions declaration section
#
#==============================================================================


#//////////////////////////////////////////////////////////////////////////////
#
# function print_usage()
#
# TODO: Add function description here
#
#//////////////////////////////////////////////////////////////////////////////
function print_usage {
    printf "Usage: show_from_log [OPTION]\n
        -l [LOG_NAME]      file path to a log from which to extract data\n
        -a [AXIS]          it can take one of the following char values:
                           'X', 'Y' or 'Z' representing axis to print
                           measurement results for\n
        -m [MSRNO]         it can take one of the following integer values:
                           1 or 2 representing exact measurement to print
                           along given axis\n
        -V                 show version info\n
        -h                 give this help list\n
Report bugs to ljubomir_kurij@protonmail.com.\n\n"
}


#//////////////////////////////////////////////////////////////////////////////
#
# function print_version()
#
# TODO: Add function description here
#
#//////////////////////////////////////////////////////////////////////////////
function print_version {
    printf "show_from_log.sh 1.0 Copyright (C) 2021 Ljubomir Kurij.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.\n\n"
}


#==============================================================================
#
# Main
#
#==============================================================================

# Check if any optin supplied, else print usage and bail out
[[ 0 = $# ]] && print_usage && exit 1

# User input storage variables
LOG_NAME=""       # Log file name
LOG_DATE=""       # Log file date
OUT_FILE_NAME=""  # File to store filtered data to
AXIS="X"          # Axis selection string
POS_DATA_INDEX=2  # Index of position data column in log
MSRNO="1"         # MEasurement selection

while getopts ":a:l:m:hV" opt; do
    case "$opt" in
        a)
            case "$OPTARG" in
                X)
                    AXIS="X"
                    POS_DATA_INDEX=2
                    ;;
                Y)
                    AXIS="Y"
                    POS_DATA_INDEX=3
                    ;;
                Z)
                    AXIS="Z"
                    POS_DATA_INDEX=4
                    ;;
                *)
                    print_usage
                    exit 1
                    ;;
            esac
            ;;
        l)
            if [[ -s "$OPTARG" ]]; then
                LOG_NAME="$OPTARG"
                LOG_DATE=$(printf "%s" "$LOG_NAME" | egrep -io "[0-9]{4}-[0-9]{2}-[0-9]{2}")
            else
                printf "show_from_log: File %s does not exist or is empty!" "$OPTARG"
                exit 1
            fi
            ;;
        m)
            case "$OPTARG" in
                1)
                    MSRNO="1"
                    ;;
                2)
                    MSRNO="2"
                    ;;
                *)
                    print_usage
                    exit 1
                    ;;
            esac
            ;;
        h)
            print_usage
            exit 0
            ;;
        V)
            print_version
            exit 0
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done

# Format output file name
printf -v OUT_FILE_NAME "%s_%s_#%s.dat" "$LOG_DATE" "$AXIS" "$MSRNO"

# Send results to standard output and to a data file
printf -v MATCH_PATTERN "%s1-%s" "$AXIS" "$MSRNO"
#printf "%s\n\n" "$MATCH_PATTERN"
cat "$LOG_NAME" | tr -d '",' | awk -v p="$MATCH_PATTERN" -v d=$POS_DATA_INDEX 'p == $1 {if (2 == d) print $2, $5; if (3 == d) print $3, $5; if (4 == d) print $4, $5}' | tee "$OUT_FILE_NAME"
