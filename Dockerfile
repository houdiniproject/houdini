FROM ruby:2.3
ARG USER
RUN mkdir /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
COPY package.json /myapp/package.json
COPY package-lock.json /myapp/package-lock.json
COPY script/debian_setup.sh /myapp/script/debian_setup.sh
WORKDIR /myapp
RUN script/debian_setup.sh
RUN groupadd -r -g 1000 $USER
RUN useradd -r -m -g $USER -u 1000 $USER
RUN chown -R $USER /usr/local/bundle
RUN chgrp -R $USER /usr/local/bundle
RUN chown -R $USER /myapp
RUN chgrp -R $USER /myapp
RUN chown -R $USER /usr/lib/node_modules
RUN chgrp -R $USER /usr/lib/node_modules
USER $USER
RUN bundle install
EXPOSE 5000
CMD foreman start
