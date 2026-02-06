# Stage 1: Build environment
FROM rust:1.82-slim AS builder

# Install linker and musl tools (essential for the slim image)
RUN apt-get update && apt-get install -y \
    musl-tools \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Add the static target
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /app
COPY . .

# Build the static binary
RUN cargo build --release --target x86_64-unknown-linux-musl

# Stage 2: Final Unikernel Filesystem
FROM scratch
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hello-unikraft /main
CMD ["/main"]
