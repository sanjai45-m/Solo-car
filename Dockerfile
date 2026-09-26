# ==============================================================================
# 🏎️ Apex Velocity Backend Server Dockerfile
# Multi-stage Ahead-Of-Time (AOT) Dart compilation for maximum performance & minimal image size
# ==============================================================================

# Stage 1: Build the AOT native server binary
FROM dart:stable AS build

WORKDIR /app

# Cache dependencies
COPY pubspec.yaml pubspec.lock* ./
RUN dart pub get

# Copy source and compile native executable
COPY . .
RUN dart compile exe bin/backend_server.dart -o bin/server

# ==============================================================================
# Stage 2: Ultra-lightweight runtime image
# ==============================================================================
FROM debian:bookworm-slim

# Install SSL certificates for outbound SMTP/TLS connections
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary from builder
COPY --from=build /app/bin/server /app/bin/server

# Expose default HTTP/WebSocket port
ENV PORT=8088
EXPOSE 8088

# Run as non-root user
USER nobody

CMD ["/app/bin/server"]
