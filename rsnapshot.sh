#!/bin/sh

echo -e "config_version\t1.2" >> /etc/rsnapshot.conf
echo -e "snapshot_root\t/snapshots" >> /etc/rsnapshot.conf
echo -e "cmd_cp\t$(which cp)" >> /etc/rsnapshot.conf
echo -e "cmd_rm\t$(which rm)" >> /etc/rsnapshot.conf
echo -e "cmd_rsync\t$(which rsync)" >> /etc/rsnapshot.conf
echo -e "cmd_ssh\t$(which ssh)" >> /etc/rsnapshot.conf
echo -e "cmd_du\t$(which du)" >> /etc/rsnapshot.conf
echo -e "cmd_rsnapshot_diff\t$(which rsnapshot-diff)" >> /etc/rsnapshot.conf
echo -e "lockfile\t/var/run/rsnapshot.pid" >> /etc/rsnapshot.conf
echo -e "link_dest\t1" >> /etc/rsnapshot.conf

NO_CREATE=1
SSHA=''
DUA=''
while [ $1 ]
do
  case $1 in
    -create) NO_CREATE=0
    ;;
    -hour) shift && H=$1
    ;;
    -day) shift && D=$1
    ;;
    -week) shift && W=$1
    ;;
    -month) shift && M=$1
    ;;
    -ssha) shift && SSHA="${SSHA} $1"
    ;;
    -dua) shift && SSHA="${DUA} $1"
    ;;
    -onefs) echo -e "one_fs\t1" >> /etc/rsnapshot.conf
    ;;
    -exc) shift && echo -e "exclude\t$1" >> /etc/rsnapshot.conf
    ;;
    -inc) shift && echo -e "include\t$1" >> /etc/rsnapshot.conf
    ;;
    -sync) echo -e "sync_first\t1" >> /etc/rsnapshot.conf
    ;;
    -lazy) echo -e "use_lazy_deletes\t$1" >> /etc/rsnapshot.conf
    ;;
    -retry) shift && echo -e "rsync_numtries\t{1}" >> /etc/rsnapshot.conf
    ;;
    -backup) shift && echo ${1} | tr '|' '\t' >> /etc/rsnapshot.conf
    ;;
    -help) cat << EOF
Options:
    -create     create the snapshot directory if not exists.
    -hour <int> the number of hourly backups.
    -day <int>  the nubmer of day backups.
    -week <int> the number of week backups.
    -month <int>  the number of month backups.
    -ssha <arg> ssh args.
    -dua <arg>  du args.
    -onefs      stick to one file system.
    -exc <pat>  exclude pattern.
    -inc <pat>  include pattern.
    -sync       pre sync flag.
    -lazy       lazy delete.
    -retry <int>  retry count.
    -backup <type>|<src>|<dest> a backup definition.
    -help       this info.
EOF
exit
    ;;
  esac
  shift
done

echo -e "no_create_root\t${NO_CREATE}" >> /etc/rsnapshot.conf

[ -e /script/preexec.sh ] && echo -e "cmd_preexec\t/script/preexec.sh" >> /etc/rsnapshot.conf
[ -e /script/postexec.sh ] && echo -e "cmd_preexec\t/script/postexec.sh" >> /etc/rsnapshot.conf
[ ${H} ] && echo -e "interval\thourly\t${H}" >> /etc/rsnapshot.conf
[ ${D} ] && echo -e "interval\tdayly\t${D}" >> /etc/rsnapshot.conf
[ ${W} ] && echo -e "interval\tweekly\t${W}" >> /etc/rsnapshot.conf
[ ${M} ] && echo -e "interval\tmonthly\t${M}" >> /etc/rsnapshot.conf
[ ${SSHA} ] && echo -e "ssh_args\t${M}" >> /etc/rsnapshot.conf
[ ${DUA} ] && echo -e "du_args\t${M}" >> /etc/rsnapshot.conf

cat /etc/rsnapshot.conf
rsnapshot configtest

if [ -d /keys ]
then
  mkdir -p /root/.ssh
  cp /keys/* /root/.ssh/
  chmod 600 /root/.ssh/*
  chown root:root /root/.ssh/*
fi

cat << EOF >> /etc/crontabs/root
0 */4         * * *           /usr/bin/rsnapshot hourly
30 3          * * *           /usr/bin/rsnapshot daily
0  3          * * 1           /usr/bin/rsnapshot weekly
30 2          1 * *           /usr/bin/rsnapshot monthly
EOF

/bin/bash /prep_ssmtp.sh

echo "starting cron..."
crond -f
