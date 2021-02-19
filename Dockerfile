FROM ubuntu:focal
RUN apt update -y
RUN apt install git zlib1g zlib1g-dev gcc-10 gcc g++ libssl-dev patch libreadline-dev libyaml-dev libffi-dev make bzip2 autoconf automake libtool bison curl libsqlite3-dev mariadb-server libmariadb-dev -y
RUN apt install redis -y
RUN useradd -ms /bin/bash dradis
RUN mkdir /mnt/backup
USER dradis
WORKDIR "/home/dradis"
RUN git clone git://github.com/sstephenson/rbenv.git .rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
RUN git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
RUN ~/.rbenv/bin/rbenv install -v 2.7.2
RUN ~/.rbenv/bin/rbenv global 2.7.2
RUN ~/.rbenv/shims/ruby -v
RUN ~/.rbenv/shims/gem install bundler
RUN git clone https://github.com/dradis/dradis-ce.git
WORKDIR "/home/dradis/dradis-ce/"
RUN sed -i 's#git@github.com:paper-trail-gem/paper_trail.git#https://github.com/paper-trail-gem/paper_trail.git#g' Gemfile
RUN sed -i "/^ruby '2.7.2'/a gem 'tzinfo-data', '~> 1.2021.1'" Gemfile
RUN sed -i 's/CleanOpenvasSettings/CleanOpenVASSettings/g' ~/dradis-ce/db/migrate/*_clean_openvas_settings.rb
RUN ~/.rbenv/shims/ruby ./bin/setup
USER root
RUN cp -a /home/dradis/dradis-ce/ /mnt/backup/
RUN chown -R dradis:dradis /mnt/backup/*
USER dradis
WORKDIR "/home/dradis/dradis-ce"
EXPOSE 3000
CMD ["/home/dradis/.rbenv/shims/bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
