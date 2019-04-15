#!/bin/bash

#
# usage:
#   ./save-dbinfo.sh [<source_dir>] [<result_file_name>]
#
# where all of the parameters are optional and have default values:
#   source_dir = "/docker-entrypoint-initdb.d"
#   result_file_name = "/var/lib/mysql/dbinfo.txt"
#
# supported file types: *.sql and *.sql.gz
#

SOURCE_DIR=${1:-"/docker-entrypoint-initdb.d"}
RESULT_FILE=${2:-"/var/lib/mysql/dbinfo.txt"}

echo -e "Import date: $(date '+%F %R')\n" > ${RESULT_FILE}
echo -e "Imported files:" >> ${RESULT_FILE}

for f in ${SOURCE_DIR}/*; do
    if [[ ( ${f} == *.sql ) || ( ${f} == *.sql.gz ) ]]; then
        # print file name with size and modification date
        echo -e "\n - ${f} (modified at $(stat -c%y ${f} | date +%F_%R), size $(stat -c%s ${f}) bytes)" >> ${RESULT_FILE}

        if [[ ${f} == *.sql  ]]; then
            echo -e "\tCREATE USER count: $(grep --count 'CREATE USER' ${f})" >> ${RESULT_FILE}
            echo -e "\tCREATE DATABASE/SCHEMA count: $(grep --count -e 'CREATE DATABASE' -e 'CREATE SCHEMA' ${f})" >> ${RESULT_FILE}
            echo -e "\tCREATE TABLE count: $(grep --count 'CREATE TABLE' ${f})" >> ${RESULT_FILE}
            echo -e "\tCREATE INDEX count: $(grep --count 'CREATE INDEX' ${f})" >> ${RESULT_FILE}
            echo -e "\tINSERT INTO count: $(grep --count 'INSERT INTO' ${f})" >> ${RESULT_FILE}
        else
            # we have to unzip file first
            echo -e "\tCREATE USER count: $(gunzip -c ${f} | grep --count 'CREATE USER')" >> ${RESULT_FILE}
            echo -e "\tCREATE DATABASE/SCHEMA count: $(gunzip -c ${f} | grep --count -e 'CREATE DATABASE' -e 'CREATE SCHEMA')" >> ${RESULT_FILE}
            echo -e "\tCREATE TABLE count: $(gunzip -c ${f} | grep --count 'CREATE TABLE')" >> ${RESULT_FILE}
            echo -e "\tCREATE INDEX count: $(gunzip -c ${f} | grep --count 'CREATE INDEX')" >> ${RESULT_FILE}
            echo -e "\tINSERT INTO count: $(gunzip -c ${f} | grep --count 'INSERT INTO')" >> ${RESULT_FILE}
        fi
    fi
done
