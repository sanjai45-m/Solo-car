# ==============================================================================
# 🏎️ Apex Velocity Backend Server Dockerfile
# Pure Dart Multi-stage AOT native compilation
# ==============================================================================

# Stage 1: Build the native server executable
FROM dart:stable AS build

WORKDIR /app

# Copy pure Dart server package and resolve dependencies
COPY server/pubspec.yaml server/pubspec.lock* ./
RUN dart pub get

# Copy server source code and compile native binary
COPY server/ ./
RUN dart compile exe bin/server.dart -o bin/server

# ==============================================================================
# Stage 2: Minimal runtime image
# ==============================================================================
FROM debian:bookworm-slim

# Install SSL root certificates for secure SMTP and HTTPS
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled AOT binary from build stage
COPY --from=build /app/bin/server /app/bin/server

# Expose HTTP / WebSocket port
ENV PORT=8088
EXPOSE 8088

# Run securely as non-root user
USER nobody

CMD ["/app/bin/server"]
