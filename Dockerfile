FROM rust:1.82-slim AS builder
RUN apt-get update && apt-get install -y musl-tools gcc && rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl
WORKDIR /app
COPY . .

# This builds the app and renames the binary to 'server' so we don't have to guess the name
RUN cargo build --release --target x86_64-unknown-linux-musl && \
    cp target/x86_64-unknown-linux-musl/release/$(cargo read-manifest | jq -r .name) ./server

FROM scratch
COPY --from=builder /app/server /main
CMD ["/main"]
