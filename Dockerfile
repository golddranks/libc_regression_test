FROM debian:jessie
MAINTAINER Pyry Kontio <pyry.kontio@drasa.eu>
USER root

ENV PREFIX=/musl

RUN apt-get update && \
  apt-get install -y \
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
  mkdir /workdir && mkdir $PREFIX

WORKDIR /workdir

ENV PATH=$PREFIX/bin:/root/.cargo/bin:$PATH \
    PKG_CONFIG_ALLOW_CROSS=true \
    PKG_CONFIG_ALL_STATIC=true \
    PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig \
    LD_LIBRARY_PATH=$PREFIX/lib

RUN TARGET="" &&\
    install_make_project () { \
      echo "Installing a library from $1" && \
      curl -sL $1 | tar xz --strip-components=1 && \
      ./configure --prefix=$PREFIX $TARGET $2 && \
      make && make install && rm -rf * ; } ; \
    install_make_project "https://www.musl-libc.org/releases/musl-1.1.16.tar.gz" ""

# Breaks:
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2017-02-16 && \
# Works:
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2017-02-13 && \
    rustup target add x86_64-unknown-linux-musl

ADD . /workdir

RUN cargo build --target=x86_64-unknown-linux-musl

CMD /bin/bash
