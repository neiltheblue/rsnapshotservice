# rsnapshot Service

rsnapshot service based on Alpine linux

This container runs a cron task and configures the rsnapshot service. There is also an sssmtp service that allows fro sending emails from the container.

## To run a server

The basic format is:

```
docker run -d \
--name snappy \
neiltheblue/rsnapshotservice \
<options>
```

To see the available options run:

```
docker run -ti neiltheblue/rsnapshotservice -help
```

```
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

```


An example run may look like this:

```
docker run -d \
--name snappy \
-v <local snapshot volume>:/snapshots \
-v <local key store>:/keys \
-v <local snapshot volume>:/snapshots \
neiltheblue/rsnapshotservice \
-hour 6 \
-day  7 \
-week 2 \
-month 1 \
-backup  'backup|/backupfiles|local' \
<other options>
```

* The snapshots are stored on the host with `-v <local snapshot volume>:/snapshots`. The `-create` option is not set to the backups will only work when a `/snapshots` volume is mounted. 
* When a volume is mounted to `/keys` then the content of the directory is copied to `/root/.ssh` in the container and used as the source for ssh calls. The keys will be chmod'ed to 600 and chown'ed by root:root in the container.
* In this example the local host data is backed up through being made availabe to the container with: `-v <local snapshot volume>:/snapshots`

The generate config file can see seen in the container logs:

`
docker logs -f snappy
`

# SSMTP support

Any environment settings starting with `SSMTP_` wil be added to the `ssmtp.conf` file. This exmple sends emails for ids<1000 to a gmail account:

```
docker run -d \
--name snappy \
-e SSMTP_root=me@gmail.com \
-e SSMTP_mailhub=smtp.gmail.com:587 \
-e SSMTP_hostname=thishost \
-e SSMTP_FromLineOverride=NO \
-e SSMTP_AuthUser=me@gmail.com \
-e SSMTP_AuthPass=mypass \
-e SSMTP_UseSTARTTLS=YES \
neiltheblue/rsnapshotservice
```

You can test this in a runing container with:

```
docker exec -ti snappy /bin/bash
```

Then enter:

```
sendmail root
test
.

```

This will send a test email to your specified gmail account.
