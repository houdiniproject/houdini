# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ruby
ARG RUBY_VERSION=3.0.7
ARG BASE_TAG=${RUBY_VERSION}-slim
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

COPY package.json yarn.lock ${RAILS_ROOT}
RUN yarn install

COPY . ${RAILS_ROOT}

# RUN bundle exec rake assets:precompile

FROM ${BASE}

ENV LANG en_US.UTF-8
RUN apt-get update -qq \
  && apt-get install -y libjemalloc2 tzdata libv8-dev curl git build-essential libpq-dev \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
  > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BASE_RELEASE=bullseye
RUN apt-get update -qq \
  && echo "deb https://apt.postgresql.org/pub/repos/apt ${BASE_RELEASE}-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list \
  && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg \
  && apt-get update -qq \
  && apt-get install -y postgresql-client-16 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://cli-assets.heroku.com/install.sh | sh

RUN groupadd --gid 1000 app && \
  useradd --uid 1000 --no-log-init --create-home --gid app app
  
USER app

COPY --from=builder --chown=app:app /app /app

ENV RAILS_ENV=development
ENV IS_DOCKER=true
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV PORT 3000
ARG RAILS_ROOT=/app/

WORKDIR $RAILS_ROOT
RUN touch /home/app/.netrc
RUN mkdir -p tmp/pids
CMD bundle check || (bundle update --bundler && bundle install -j4 --retry 3) && foreman start