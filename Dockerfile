FROM alpine:3.4

RUN apk --no-cache add rsnapshot

COPY rsnapshot.sh /rsnapshot.sh

ENTRYPOINT ["/bin/sh", "/rsnapshot.sh"]
