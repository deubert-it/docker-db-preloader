#!/bin/bash

#
# usage:
#   ./show-dbinfo.sh [<result_file_name>]
#
# where all of the parameters are optional and have default values:
#   result_file_name = "/var/lib/mysql/dbinfo.txt"
#

RESULT_FILE=${1:-"/var/lib/mysql/dbinfo.txt"}

if [[ -f ${RESULT_FILE} ]]; then
    echo "" # just extra new line
    cat ${RESULT_FILE}
    echo "" # just extra new line
else
    echo -e "\nFile ${RESULT_FILE} not found!\n"
fi
