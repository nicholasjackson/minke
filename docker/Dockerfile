FROM debian:stable

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update
RUN apt-get -y install procps build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison rubygems

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && curl -L get.rvm.io | bash -s stable --ruby=2.3.1 --with-gems="bundle"

COPY Gemfile Gemfile

RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm @global do bundle install"
