# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM rust:1.68 AS builder
WORKDIR /app
ARG TARGETARCH
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apt update && apt install -y build-essential gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu
RUN export ARCH=$(case $TARGETARCH in "arm64") echo "aarch64";; *) echo "x86_64";; esac) && \
    export RUSTFLAGS="-C linker=$ARCH-linux-gnu-gcc" && \
    export CARGO_BUILD_TARGET=$ARCH-unknown-linux-gnu && \
    rustup target add $CARGO_BUILD_TARGET
RUN cargo install --locked \
    mdbook@0.4.25
# Do you want a .gitignore to be created? (y/n)
# What title would you like to give the book?
# RUN echo \n\n | mdbook init
# RUN mdbook-mermaid install
# RUN mdbook-admonish install

# FROM gcr.io/distroless/cc as runner
# WORKDIR /app
# COPY --from=builder --link /usr/local/cargo/bin/mdbook* /usr/bin/

# CMD ["mdbook", "--help"]

# FROM runner AS builder1
# WORKDIR /app
# COPY test_book .
# RUN ["mdbook", "build"]

# FROM nginx:alpine AS webserver
# COPY --from=builder1 /app/book/html /usr/share/nginx/html
# EXPOSE 80