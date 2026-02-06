Rust Unikernel on Unikraft CloudThis project demonstrates how to build and deploy a high-performance Rust web server as a Unikernel on Unikraft Cloud. Unlike a traditional Docker container, this application runs without a guest OS (no Linux, no Shell), resulting in sub-20ms boot times and a minimal memory footprint.🛠 PrerequisitesUnikraft Cloud Account: Sign up here.KraftKit CLI: Installed via curl -sSfL https://get.kraftkit.sh | sh.Docker / Colima: Used for the build environment (Packaging).Rust: Local installation for development.

🚀 Quick Start (The "No-Headache" Path)1. Environment SetupTo avoid "Illegal Base64" and "Permission Denied" errors, use the following variables in your terminal. 
==> Important: If you are using Colima on macOS, the DOCKER_HOST line is mandatory.

Bash# Set your credentials (Replace with your actual token)
export UKC_TOKEN="YOUR_UNIKRAFT_TOKEN"
export UKC_METRO="fra"

# Fix for Colima/Docker on macOS
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
2. Prepare the Static BuildUnikraft requires a fully static binary (musl) because there is no Linux dynamic loader (ld-linux) in the unikernel.Dockerfile:DockerfileFROM rust:1.82 AS builder
RUN rustup target add x86_64-unknown-linux-musl
WORKDIR /app
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM scratch
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hello-unikraft /main
CMD ["/main"]

3. Deploy to the CloudBashkraft cloud deploy .
⚠️ Issues We Faced & Solutions1. Token Decoding ErrorsError: could not decode token: illegal base64 data at input byte 4Cause: Hidden characters or newlines in the ~/.zshrc file or the shell environment.Fix: Avoid saving the token in the profile if it remains buggy. Instead, prefix your commands or ensure no spaces exist when exporting: export UKC_TOKEN="your_token".2. Missing Linux LibrariesError: Failed to execute /lib64/ld-linux-x86-64.so.2: No such file or directoryCause: The Rust binary was dynamically linked to Linux libraries. Unikraft is "Bare Metal" and doesn't have a /lib64 folder.Fix: Use the x86_64-unknown-linux-musl target to create a static binary that contains all necessary code internally.3. Docker Connectivity (Colima)Error: could not connect to buildkit: could not start ephemeral BuildKit containerCause: kraft looks for the Docker socket at /var/run/docker.sock, but Colima stores it in the user's home directory.Fix: Set DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock".4. Git BloatError: Accidental commit of the .unikraft folder.Fix: Use a .gitignore to ignore build artifacts. If committed by mistake on the first commit, use:Bashgit update-ref -d HEAD
echo ".unikraft/" >> .gitignore
git add .
git commit -m "Initial clean commit"
📊 Performance BenchmarkMetricTraditional VMDocker (Linux)Unikraft CloudBoot Time~30-60 seconds~1-2 seconds~15-20 millisecondsRAM Overhead~512MB+~100MB+~2MBAttack SurfaceHigh (Entire OS)Medium (Shared Kernel)Minimal (App only)


//Deploying via Github actions 
Save token inside repository secret key
we will change docker to slim to save github action minutes
