FROM debian:stable

ENV COMPOSE_VERSION 1.7.1
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  # Build-time metadata as defined at http://label-schema.org
  ARG BUILD_DATE
  ARG VCS_REF
  LABEL org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.docker.dockerfile="/docker/Dockerfile" \
        org.label-schema.license="MIT" \
        org.label-schema.name="Minke" \
        org.label-schema.url="https://minke.rocks" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-type="Git" \
        org.label-schema.vcs-url="https://github.com/nicholasjackson/minke"

RUN apt-get update
RUN apt-get -y install procps build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison rubygems ca-certificates apt-transport-https

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

RUN echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list

RUN apt-get update
RUN apt-get -y install docker-engine

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && curl -L get.rvm.io | bash -s stable --ruby=2.3.1 --with-gems="bundle"

RUN curl -o /usr/local/bin/docker-compose -L \
		"https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64" \
	&& chmod +x /usr/local/bin/docker-compose

COPY .bashrc /root/.bashrc

COPY Gemfile Gemfile
COPY minke.gem /root/minke.gem

RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm @global do gem install /root/minke.gem && bundle install"
