FROM alpine:3.4

RUN apk --no-cache add rsnapshot
RUN apk --no-cache add ssmtp

COPY rsnapshot.sh /rsnapshot.sh
COPY prep_ssmtp.sh /prep_ssmtp.sh

ENTRYPOINT ["/bin/sh", "/rsnapshot.sh"]
