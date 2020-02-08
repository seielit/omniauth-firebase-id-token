#!/bin/bash

if [ ! -f Gemfile.lock ]; then
  docker run --rm -v "$PWD":/src -w /src ruby:2.5 bundle install --binstubs=/src/vendor/bundle/bin --path=/src/vendor/bundle
fi

docker build -t omniauth-firebase-id-token .

docker run --rm -v "$PWD":/src -w /src omniauth-firebase-id-token bundle install
