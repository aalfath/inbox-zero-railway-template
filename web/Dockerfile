# Inbox Zero web app (Next.js + API), pinned to the upstream v2.30.0 release image.
FROM ghcr.io/elie222/inbox-zero:2.30.0@sha256:e9970c499a79b8a15bbab21363d1b87ea247c75b2721f036c7cee0e2c78d1fcc
COPY railway-start.sh /app/docker/scripts/railway-start.sh
RUN chmod +x /app/docker/scripts/railway-start.sh
EXPOSE 3000
CMD ["/app/docker/scripts/railway-start.sh"]
