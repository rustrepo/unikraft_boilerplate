# This image is ~600MB smaller than the standard one
FROM rust:1.82-alpine AS builder
RUN apk add --no-network --no-cache musl-dev gcc

# Install the musl target
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /app
COPY . .

# Build with static linking
RUN cargo build --release --target x86_64-unknown-linux-musl

# Use an empty final image
FROM scratch
# The binary path must match the musl target folder
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hello-unikraft /main
CMD ["/main"]
