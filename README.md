[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/inbox-zero-1?utm_medium=integration&utm_source=button&utm_campaign=inbox-zero)

# Inbox Zero on Railway

One-click Railway template for [Inbox Zero](https://github.com/elie222/inbox-zero), the open-source AI email assistant for Gmail and Outlook. It deploys upstream's full self-hosted stack:

| Service | Built from | What it does |
|---|---|---|
| **Inbox Zero** | `web/` (`ghcr.io/elie222/inbox-zero:2.30.0`, pinned by digest) | Next.js web app and API on the public domain. Runs the database migrations on start, retrying until Postgres is ready. |
| **Worker** | `worker/` (same image) | BullMQ worker: pulls background jobs (automation, digests, summaries) from Redis and forwards them to the web app over the private network. |
| **Cron** | `cron/` (`alpine:3.24.4`, busybox wget) | Calls the app's scheduled-job endpoints: scheduled actions, automation jobs, follow-ups, digests, meeting briefs, Gmail/Outlook watch renewal, daily retention. |
| **Redis HTTP** | `redis-http/` (`hiett/serverless-redis-http:0.0.10`) | Upstash-compatible REST proxy in front of Redis, as in upstream's `docker-compose.yml`. |
| **Postgres** | Railway Postgres | Users, accounts, rules, history, encrypted OAuth tokens. Volume. |
| **Redis** | Railway Redis | Cache, rate limits, BullMQ queues and live updates. Volume. |

Every service except the two databases builds from this repository, so Railway shows an "update available" notice to deployers when this repo's `main` changes.

## Variables

Generated or wired by the template: `AUTH_SECRET`, `EMAIL_ENCRYPT_SECRET`, `EMAIL_ENCRYPT_SALT`, `INTERNAL_API_KEY`, `CRON_SECRET`, `API_KEY_SALT`, `GOOGLE_PUBSUB_VERIFICATION_TOKEN`, `MICROSOFT_WEBHOOK_CLIENT_STATE`, the Redis HTTP token, the database and Redis URLs, and `NEXT_PUBLIC_BASE_URL` (the service's Railway domain).

You fill in at deploy time:

- `AUTH_ALLOWED_EMAILS`: the email addresses allowed to sign up (comma-separated). Everyone else is refused.
- `LLM_API_KEY`: the API key for `DEFAULT_LLM_PROVIDER` (default `anthropic`; also `openai`, `google`, `openrouter`, `groq` and others). Optional: `DEFAULT_LLM_MODEL`.

Optional, set after the first deploy once you know the service's domain (the app boots without them, using upstream's `skipped` placeholder for Google):

- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_PUBSUB_TOPIC_NAME` for Gmail ([upstream guide](https://docs.getinboxzero.com/hosting/google-oauth)).
- `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET` (and `MICROSOFT_TENANT_ID`) for Outlook ([upstream guide](https://docs.getinboxzero.com/hosting/microsoft-oauth)).

Redirect URIs use your domain: `https://YOUR-DOMAIN/api/auth/callback/google`, `https://YOUR-DOMAIN/api/google/linking/callback`, `https://YOUR-DOMAIN/api/auth/callback/microsoft`, `https://YOUR-DOMAIN/api/outlook/linking/callback`.

## Updates

Version bumps land here as a change to the pinned image in `web/Dockerfile` and `worker/Dockerfile`, with a `CHANGELOG.md` entry (breaking changes first). Railway then offers the update in your project; you choose when to apply it. Database migrations run automatically when the new web service starts.

## Layout

- `web/`: Dockerfile and `railway-start.sh` (IPv6 listen, empty-variable cleanup, migration retry, then upstream's `start.sh`).
- `worker/`: Dockerfile running upstream's `start-worker.sh`.
- `cron/`: Dockerfile and `cron.sh`.
- `redis-http/`: Dockerfile with the proxy's fixed settings.

Inbox Zero is licensed AGPL-3.0 with additional terms by Inbox Zero Inc. (no reselling the software itself). This repo only packages it for Railway.
