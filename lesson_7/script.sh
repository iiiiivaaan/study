#!/bin/bash

MAIL="./mail"
LOCK="/tmp/_du_lock"
LOG=`find ./ -name "*.log"`
TIME_1=`head -n1 ${LOG} | awk '{print $4,$5}' | sed 's/\[//;s/\]//'`
TIME_2=`tail -n1 ${LOG} | awk '{print $4,$5}' | sed 's/\[//;s/\]//'`
USER=`env | grep -i username | awk -F'=' '{print $2}'`

:>${MAIL}

if [ -f ${LOCK} ]; then 
   echo "Script already run. Wait."
   exit 0
else
   touch ${LOCK}
fi

sleep 1

echo "Обрабатываемый временной диапазон: " ${TIME_1} "-" ${TIME_2} >> ${MAIL}
echo "IP адресов (с наибольшим кол-вом запросов):" >> ${MAIL}
cat ${LOG} | awk '{print $1}' | sort | uniq -c | sort -nr | head -n15 >> ${MAIL}
echo "Запрашиваемых адресов (с наибольшим кол-вом запросов):" >> ${MAIL}
cat ${LOG} | egrep "GET|POST" | awk '{print $7}' | sort | uniq -c | sort -nr | head -n15 >> ${MAIL}
echo "Все ошибки:" >> ${MAIL}
grep "HTTP\/1.1. 4.." ${LOG} | awk '{print $9}' | sort | uniq -c | sort -nr >> ${MAIL}
grep "HTTP\/1.1. 5.." ${LOG} | awk '{print $9}' | sort | uniq -c | sort -nr >> ${MAIL}
echo "Список всех кодов возврата:" >> ${MAIL}
grep "HTTP\/1.1. ..." ${LOG} | awk '{print $9}' | sort | uniq -c | sort -nr >> ${MAIL}

TEST_SEND=`mail --version 2>/dev/null`
if [ ${?} == 127 ]; then
   echo "Install mailutils!"
   rm -f ${LOCK}
   exit 1
fi

cat ${MAIL} | mail -s "Report" ${USER}@localhost

rm -f ${LOCK}
