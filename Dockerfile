# syntax=docker/dockerfile:1
FROM ubuntu:20.04

ARG HOME=/root

# -1. (Optional) Add Ubuntu Repo
ADD docker/registryList /etc/apt/
RUN sed -i "1r /etc/apt/registryList" /etc/apt/sources.list

# 0. Install general tools
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        python3 \
        wget


RUN apt-get install -y \
        autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev \
        gawk build-essential bison flex texinfo gperf libtool patchutils bc \
        zlib1g-dev libexpat-dev git \
        ninja-build pkg-config libglib2.0-dev libpixman-1-dev

# 1. Set up Rust
WORKDIR ${HOME}
# - https://learningos.github.io/rust-based-os-comp2022/0setup-devel-env.html#qemu
# - https://www.rust-lang.org/tools/install
# - https://github.com/rust-lang/docker-rust/blob/master/Dockerfile-debian.template

# 1.1. Install
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=nightly
RUN set -eux; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;

# 1.2. Sanity checking
RUN rustup --version && \
    cargo --version && \
    rustc --version

# 2. Build env for labs
RUN rustup target add riscv64gc-unknown-none-elf && \
    cargo install cargo-binutils --vers ~0.2 && \
    rustup component add rust-src && \
    rustup component add llvm-tools-preview
RUN cargo install rustlings

# Ready to go
WORKDIR ${HOME}
