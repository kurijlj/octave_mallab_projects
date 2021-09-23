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
	echo -e "Usage: slckaddpkgs.sh [OPTION]" >&2
	echo -e "" >&2
	echo -e "    -l [LOG_NAME]      file path to a log from which to extract data" >&2
	echo -e "" >&2
	echo -e "    -a [AXIS]          it can take one of the following char values:">&2
	echo -e "                       'X', 'Y' or 'Z' representing axis to print measurement" >&2
	echo -e "                       results for" >&2
	echo -e "" >&2
	echo -e "    -m [MSRNO]         it can take one of the following integer values:" >&2
	echo -e "                       1 or 2 representing exact measurement to print" >&2
	echo -e "                       along given axis" >&2
	echo -e "" >&2
	echo -e "    -h                 give this help list" >&2
	echo -e "" >&2
	echo -e "Report bugs to ljubomir_kurij@protonmail.com." >&2
	echo -e "" >&2
}


#//////////////////////////////////////////////////////////////////////////////
#
# function print_version()
#
# TODO: Add function description here
#
#//////////////////////////////////////////////////////////////////////////////
function print_version {
	echo -e "show_from_log.sh 1.0 Copyright (C) 2021 Ljubomir Kurij." >&2
	echo -e "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>" >&2
	echo -e "This is free software: you are free to change and redistribute it." >&2
	echo -e "There is NO WARRANTY, to the extent permitted by law." >&2
	echo -e "" >&2
}


#==============================================================================
#
# Main
#
#==============================================================================

# Check if any optin supplied, else print usage and bail out
[[ 0 = $# ]] && print_usage && exit 1

# User input storage variables
LOG_NAME=""  # Log file name
AXIS="X"      # Axis selection string
MSRNO=1      # MEasurement selection

while getopts ":a:l:m:hv" opt; do
    case "$opt" in
        a)
            case "$OPTARG" in
                X)
                    AXIS="X"
                    ;;
                Y)
                    AXIS="Y"
                    ;;
                Z)
                    AXIS="Z"
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
            else
                echo -e "show_from_log: File $OPTARG does not exist or is empty!" >&2
                exit 1
            fi
            ;;
        m)
            case "$OPTARG" in
                1)
                    MSRNO=1
                    ;;
                2)
                    MSRNO=2
                    ;;
                *)
                    print_usage
                    exit 1
                    ;;
            esac
            ;;
        h)
            print_usage
            ;;
        v)
            print_version
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done

echo -e "$LOG_NAME $AXIS #$MSRNO" >&2
