#!/bin/bash

/bin/time -f %E -o /tmp/nice_1.log nice -n -20 dd if=/dev/random of=/dev/null bs=1M count=500 status=none
echo "Nice -20" >> /tmp/nice_1.log
echo " " >> /tmp/nice_1.log
/bin/time -f %E -o /tmp/nice_2.log nice -n 19 dd if=/dev/random of=/dev/null bs=1M count=500 status=none
echo "Nice 19" >> /tmp/nice_2.log

cat /tmp/nice_1.log /tmp/nice_2.log > log.log
cat log.log
