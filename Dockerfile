# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ruby
ARG RUBY_VERSION=3.3.8
ARG BASE_TAG=${RUBY_VERSION}-slim
ARG BASE=${BASE_IMAGE}:${BASE_TAG}

FROM ${BASE} AS builder

ENV LANG=en_US.UTF-8

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  tzdata \
  git \
  nodejs \
  yarn \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
  > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG RAILS_ROOT=/app/

RUN mkdir ${RAILS_ROOT}
WORKDIR ${RAILS_ROOT}

COPY package.json yarn.lock ${RAILS_ROOT}
RUN yarn install

COPY . ${RAILS_ROOT}

# RUN bundle exec rake assets:precompile

FROM ${BASE}

ENV LANG=en_US.UTF-8
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  libjemalloc2 \
  tzdata \
  libv8-dev \
  curl \
  git \
  build-essential \
  libpq-dev \
  libyaml-dev \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
  > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BASE_RELEASE=bookworm
RUN apt-get update -qq \
  && echo "deb https://apt.postgresql.org/pub/repos/apt ${BASE_RELEASE}-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list \
  && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends postgresql-client-16 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://cli-assets.heroku.com/install.sh | sh

RUN groupadd --gid 1000 app && \
  useradd --uid 1000 --no-log-init --create-home --gid app app

USER app

COPY --from=builder --chown=app:app /app /app

ENV RAILS_ENV=development
ENV RUBY_STDOUT_SYNC=true
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV LD_PRELOAD="libjemalloc.so.2"
ENV RUBY_YJIT_ENABLE=1
ENV MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true"
ENV IS_DOCKER=true
ARG RAILS_ROOT=/app/
ARG PORT=5000

WORKDIR $RAILS_ROOT
RUN touch /home/app/.netrc
RUN mkdir -p tmp/pids
RUN bundle check || (bundle update --bundler && bundle install -j4 --retry 3)

CMD ["bin/dev"]
