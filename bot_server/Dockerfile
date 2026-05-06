# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# Copy the rest of the source code
COPY . .

# Compile to a native executable
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage - use a minimal image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080

CMD ["/app/bin/server"]
