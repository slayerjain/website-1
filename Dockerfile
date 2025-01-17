# Credit to Julien Guyomard (https://github.com/jguyomard). This Dockerfile
# is essentially based on his Dockerfile at
# https://github.com/jguyomard/docker-hugo/blob/master/Dockerfile. The only significant
# change is that the Hugo version is now an overridable argument rather than a fixed
# environment variable.

FROM golang:1.16-alpine

LABEL maintainer="Luc Perkins <lperkins@linuxfoundation.org>"

RUN apk add --no-cache \
    curl \
    gcc \
    g++ \
    musl-dev \
    build-base \
    libc6-compat

ARG HUGO_VERSION

RUN mkdir $HOME/src && \
    cd $HOME/src && \
    curl -L https://github.com/gohugoio/hugo/archive/refs/tags/v${HUGO_VERSION}.tar.gz | tar -xz && \
    cd "hugo-${HUGO_VERSION}" && \
    go install --tags extended

FROM golang:1.16-alpine

RUN apk add --no-cache \
    git \
    openssh-client \
    rsync \
    npm && \
    npm install -D autoprefixer postcss-cli

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    addgroup -Sg 1000 hugo && \
    adduser -Sg hugo -u 1000 -h /src hugo

COPY --from=0 /go/bin/hugo /usr/local/bin/hugo

WORKDIR /src

USER hugo:hugo

EXPOSE 1313
