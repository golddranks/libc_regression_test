FROM debian:jessie
MAINTAINER Pyry Kontio <pyry.kontio@drasa.eu>
USER root

RUN apt-get update && \
  apt-get install -y \
  musl-dev \
  bzip2 \
  make \
  curl \
  pkgconf \
  git \
  xutils-dev \
  g++ \
  file \
  nano \
  ca-certificates \
  --no-install-recommends && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir /workdir

WORKDIR /workdir

ENV PATH=/root/.cargo/bin:$PATH

# Breaks:
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2017-02-16 && \
# Works:
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2017-02-13 && \
    rustup target add x86_64-unknown-linux-musl

ADD . /workdir

RUN cargo build --target=x86_64-unknown-linux-musl

CMD /bin/bash
