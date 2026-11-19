#!/bin/sh
# Calls Inbox Zero's scheduled-job endpoints (upstream v2.30.0 docker-compose.yml
# `cron` service, plus the daily retention jobs from its self-hosting guide).
set -u

: "${INBOX_ZERO_URL:?INBOX_ZERO_URL is not set}"
: "${CRON_SECRET:?CRON_SECRET is not set}"
URL="${INBOX_ZERO_URL%/}"

echo "[cron] waiting for Inbox Zero at $URL"
until curl -fs -o /dev/null "$URL/api/health"; do sleep 5; done
echo "[cron] Inbox Zero is up, starting job loops"

job() { # <path> <interval seconds> [initial delay seconds]
  sleep "${3:-0}"
  while true; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 600 \
      -H "Authorization: Bearer $CRON_SECRET" "$URL$1") || code=000
    echo "[cron] $1 -> $code"
    sleep "$2"
  done
}

job /api/cron/scheduled-actions 900 &
job /api/cron/automation-jobs 900 &
job /api/follow-up-reminders 3600 &
job /api/resend/digest/all 1800 &
job /api/meeting-briefs 900 &
job /api/watch/all 21600 &
job /api/cron/reasoning-retention 86400 300 &
job /api/cron/draft-cleanup 86400 300 &
wait
