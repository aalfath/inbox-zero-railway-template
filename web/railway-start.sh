#!/bin/sh
# Railway start wrapper for the Inbox Zero web service.
set -e

# Listen on IPv4 and IPv6 (Railway's private network) on Railway's PORT.
export PORT="${PORT:-3000}"
export HOSTNAME="::"

# Fixed settings for a self-hosted Railway deploy.
export QUEUE_BACKEND="${QUEUE_BACKEND:-bullmq}"
export NEXT_PUBLIC_BYPASS_PREMIUM_CHECKS="${NEXT_PUBLIC_BYPASS_PREMIUM_CHECKS:-true}"
export NEXT_PUBLIC_EMAIL_SEND_ENABLED="${NEXT_PUBLIC_EMAIL_SEND_ENABLED:-true}"
export INTERNAL_API_URL="${INTERNAL_API_URL:-http://localhost:$PORT}"
export DIRECT_URL="${DIRECT_URL:-$DATABASE_URL}"

# Railway creates optional variables as empty strings; some of them fail
# Inbox Zero's env validation when empty, so drop the empty ones.
for v in DEFAULT_LLM_MODEL ECONOMY_LLM_PROVIDER ECONOMY_LLM_MODEL MICROSOFT_CLIENT_ID \
         MICROSOFT_CLIENT_SECRET MICROSOFT_TENANT_ID AUTH_ALLOWED_EMAIL_DOMAINS QUEUE_BACKEND; do
  eval "val=\${$v-}"
  [ -z "$val" ] && unset "$v"
done

# Google OAuth is set after the first deploy (its redirect URIs need this
# service's domain). Until then, boot with upstream's documented "skipped"
# value so the app starts and the deployer can read the domain.
for v in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET GOOGLE_PUBSUB_TOPIC_NAME; do
  eval "val=\${$v-}"
  if [ -z "$val" ]; then
    echo "[railway] $v is not set yet: using 'skipped' (see the template README to connect Gmail)"
    export "$v=skipped"
  fi
done

# Postgres may still be starting on a fresh deploy. Upstream's start.sh logs a
# failed migration and boots anyway (an app with no tables), so retry here
# until the migrations succeed, then let start.sh skip them.
i=0
until /app/docker/scripts/migrate.sh; do
  i=$((i + 1))
  if [ "$i" -ge 60 ]; then
    echo "[railway] database migrations failed 60 times, giving up"
    exit 1
  fi
  echo "[railway] retrying database migrations in 5s ($i/60)"
  sleep 5
done
export SKIP_DB_MIGRATIONS=true

exec /app/docker/scripts/start.sh
