# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM rust:1.68 AS builder
ARG TARGETARCH
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apt update && apt install -y build-essential gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu
RUN export ARCH=$(case $TARGETARCH in "arm64") echo "aarch64";; *) echo "x86_64";; esac) && \
    export RUSTFLAGS="-C linker=$ARCH-linux-gnu-gcc" && \
    export CARGO_BUILD_TARGET=$ARCH-unknown-linux-gnu && \
    rustup target add $CARGO_BUILD_TARGET
RUN cargo install --locked \
    mdbook-toc@^0.11.0 \
    mdbook-mermaid@^0.12.6 \
    mdbook-admonish@^1.8.0  \
    mdbook-linkcheck@^0.7.0  \
    mdbook-pdf@^0.1.5  \
    mdbook@^0.4.25

FROM gcr.io/distroless/cc
COPY --from=builder --link /usr/local/cargo/bin/mdbook* /usr/bin/
CMD ["mdbook", "--help"]