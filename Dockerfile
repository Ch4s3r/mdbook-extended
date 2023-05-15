# syntax=docker/dockerfile:1.4
FROM rust:1.69-slim AS builder
WORKDIR /app
ARG TARGETARCH
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
RUN apt-get update && apt-get install -y build-essential
RUN cargo install --locked mdbook-toc@0.11.0
RUN cargo install --locked mdbook-mermaid@0.12.6
RUN cargo install --locked mdbook-admonish@1.8.0
RUN cargo install --locked mdbook-linkcheck@0.7.7
RUN cargo install --locked mdbook@0.4.25
RUN cargo install --locked toml-cli@0.2.3

FROM debian:stable-slim
WORKDIR /app
COPY --from=builder          --link /usr/local/cargo/bin/mdbook*     /usr/bin/
COPY --from=builder          --link /usr/local/cargo/bin/toml*       /usr/bin/
RUN mdbook init --title none --ignore none
RUN mdbook-mermaid install
RUN mdbook-admonish install
RUN toml get book.toml preprocessor.admonish.assets_version > .admonish_assets_version
COPY mdbook_build_wrapper.sh .
ENTRYPOINT ["mdbook", "--help"]
