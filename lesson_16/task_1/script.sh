#!/bin/bash

setenforce 0

cat << EOF > /etc/sysconfig/watchdog
WORD="Error"
LOG=/var/log/anaconda/journal.log
EOF

cat << EOF > /opt/watchlog.sh
#!/bin/bash
WORD=\${1}
LOG=\${2}
DATE=\`date\`
if grep \${WORD} \${LOG} &> /dev/null
then
  logger "\${DATE}: I found word, Master!"
else
  exit 0
fi
EOF

cat <<EOF > /usr/lib/systemd/system/my_wathdog.service
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchdog
ExecStart=/opt/watchlog.sh \${WORD} \${LOG}
EOF

cat <<ONE > /usr/lib/systemd/system/my_wathdog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=my_wathdog.service
[Install]
WantedBy=multi-user.target
ONE

chmod 700 /opt/watchlog.sh
systemctl daemon-reload
systemctl start my_wathdog.timer
systemctl start my_wathdog.service
