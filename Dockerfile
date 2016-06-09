FROM alpine:3.4

RUN apk --no-cache add rsnapshot

COPY rsnapshot.sh /rsnapshot.sh
COPY prep_ssmtp.sh /prep_ssmtp.sh

ENTRYPOINT ["/bin/sh", "/rsnapshot.sh"]
