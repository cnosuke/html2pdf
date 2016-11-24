FROM cnosuke/ruby23-base
MAINTAINER cnosuke

RUN apt-get update && \
  apt-get install -y \
  curl \
  zip \
  wkhtmltopdf

RUN curl -o IPAexfont00301.zip http://dl.ipafont.ipa.go.jp/IPAexfont/IPAexfont00301.zip && \
  unzip IPAexfont00301.zip && \
  mv -f IPAexfont00301/ /usr/share/fonts

RUN mkdir -p /app/tmp /app/log /app/public /tmp/socks
WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app/

COPY .git/logs/HEAD /GIT_LOGS
RUN tail -1 /GIT_LOGS |awk '{print $2}' > /app/REVISION

EXPOSE 8080
CMD ["bundle", "exec", "unicorn", "-E", "production", "-c", "unicorn.rb"]
