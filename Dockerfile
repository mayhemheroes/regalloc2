## Build stage
FROM rust as builder
RUN rustup toolchain add nightly
RUN rustup default nightly
RUN cargo +nightly install -f cargo-fuzz
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl

## Add source code
ADD . /async-h1
WORKDIR /async-h1/fuzz

RUN cargo fuzz build

# Package Stage
FROM ubuntu:20.04
COPY --from=builder /async-h1/fuzz/target/x86_64-unknown-linux-gnu/release/domtree /
COPY --from=builder /async-h1/fuzz/target/x86_64-unknown-linux-gnu/release/ion /
COPY --from=builder /async-h1/fuzz/target/x86_64-unknown-linux-gnu/release/ion_checker /
COPY --from=builder /async-h1/fuzz/target/x86_64-unknown-linux-gnu/release/moves /
COPY --from=builder /async-h1/fuzz/target/x86_64-unknown-linux-gnu/release/ssagen /
