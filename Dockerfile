# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ruby
ARG BASE_TAG=2.7.6-slim
ARG BASE=${BASE_IMAGE}:${BASE_TAG}

FROM ${BASE} AS builder

ENV LANG en_US.UTF-8

RUN apt-get update -qq \
  && apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  tzdata \
  git \
  libpq-dev \
  nodejs \
  yarn \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
  > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG RAILS_ROOT=/app/

RUN mkdir ${RAILS_ROOT}
WORKDIR ${RAILS_ROOT}

COPY Gemfile* ${RAILS_ROOT}
ADD gems ${RAILS_ROOT}gems

RUN bundle install -j4 --retry 3

COPY package.json yarn.lock ${RAILS_ROOT}
RUN yarn install

COPY . ${RAILS_ROOT}

RUN bundle exec rake assets:precompile

FROM ${BASE}

ENV LANG en_US.UTF-8

RUN apt-get update -qq \
  && apt-get install -y libjemalloc2 postgresql-client tzdata libv8-dev nodejs

RUN groupadd --gid 1000 app && \
  useradd --uid 1000 --no-log-init --create-home --gid app app
USER app

COPY --from=builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV PORT 3000
ARG RAILS_ROOT=/app/

WORKDIR $RAILS_ROOT
RUN mkdir -p tmp/pids
CMD bundle exec puma -p $PORT -C ./config/puma.rb