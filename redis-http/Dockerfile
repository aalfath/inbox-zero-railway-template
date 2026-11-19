# serverless-redis-http: the Upstash-compatible REST proxy in front of Redis
# that upstream's docker-compose.yml uses.
FROM hiett/serverless-redis-http:0.0.10@sha256:65128347949bca511e448fd7238780d624573d74c22b79155a7563db19e9b678
# One Redis connection from SRH_TOKEN / SRH_CONNECTION_STRING, on port 80,
# listening on IPv6 for Railway's private network.
ENV SRH_MODE=env \
    SRH_PORT=80 \
    SRH_IPV6=true
EXPOSE 80
