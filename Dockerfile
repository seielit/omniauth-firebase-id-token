FROM ruby:2.6

RUN mkdir -p /src
WORKDIR /src

COPY Gemfile /src/Gemfile
COPY Gemfile.lock /src/Gemfile.lock
COPY omniauth-firebase-id-token.gemspec /src/omniauth-firebase-id-token.gemspec
COPY lib /src/lib

ENV BUNDLE_GEMFILE=/src/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/src/vendor/bundle \
  GEM_PATH=/src/vendor/bundle \
  BUNDLE_APP_CONFIG=/src/vendor/bundle \
  BUNDLE_BIN=/src/vendor/bundle/bin \
  BUNDLE_BINSTUBS=/src/vendor/bundle/binstubs \
  PATH=/src/vendor/bundle/bin:$PATH

RUN bundle update --bundler
RUN bundle install

COPY . .

CMD ["rspec"]
