# Stage 1: The Build environment
# We use 'slim' to save download time on the GitHub runner
FROM rust:1.82-slim AS builder

# Install the linker and musl tools required for static compilation
RUN apt-get update && apt-get install -y \
    musl-tools \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Add the target for a statically linked Linux binary
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /app

# Copy your source code into the container
COPY . .

# Build the application in release mode for the musl target
RUN cargo build --release --target x86_64-unknown-linux-musl

# Stage 2: The Final Unikernel Filesystem
# We start from 'scratch' (0mb) to keep the unikernel tiny
FROM scratch

# This COPY command finds the binary in the release folder.
# The '*' wildcard ensures it works regardless of your project's name.
# It renames the binary to 'main' so the CMD is always consistent.
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hello-unikraft /main

# The command Unikraft Cloud will execute on boot
CMD ["/main"]
