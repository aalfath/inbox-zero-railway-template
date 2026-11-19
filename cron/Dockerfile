# Scheduled jobs: calls Inbox Zero's cron endpoints on fixed intervals, as the
# `cron` service in upstream's docker-compose.yml does.
FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
RUN apk add --no-cache curl
COPY cron.sh /cron.sh
RUN chmod +x /cron.sh
CMD ["/cron.sh"]
