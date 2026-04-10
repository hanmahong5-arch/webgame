# Stage 1: Build Elixir release
FROM elixir:1.17-otp-27-slim AS builder

RUN apt-get update -y && \
    apt-get install -y git build-essential ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Install dependencies first (cache layer)
COPY mix.exs mix.lock ./
COPY deps_local/ deps_local/
RUN mix deps.get --only prod && mix deps.compile

# Copy config (needed before compile for config-time values)
COPY config/ config/

# Copy application source
COPY lib/ lib/
COPY assets/ assets/
COPY priv/ priv/

# Build assets, compile, digest, and create release
RUN mix assets.deploy && \
    mix compile && \
    mix phx.digest && \
    mix release

# Stage 2: Runtime
FROM debian:bookworm-slim

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/lurus_www ./

# PHX_SERVER=true is CRITICAL — without it the HTTP server doesn't start in release mode
ENV PHX_SERVER=true
ENV PORT=4000
# Allow 25s for WebSocket drain before BEAM exits (K8s terminationGracePeriod=30s)
ENV RELEASE_SHUTDOWN_TIMEOUT=25000

# Run as non-root (nobody)
USER 65534

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:4000/health || exit 1

CMD ["/app/bin/lurus_www", "start"]
