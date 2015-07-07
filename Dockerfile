FROM ubuntu
MAINTAINER  kuenstner@gmail.com

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install wget zsh unzip vim curl git default-jdk php5-cli php5-curl \
    openjdk-7-jre-headless python-software-properties mailutils sendmail sendmail-bin \
    mutt
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# Apt Sources
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb http://packages.elasticsearch.org/elasticsearch/1.6/debian stable main" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install elasticsearch

# Elasticsearch
# marvel
RUN /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest

# kopf
RUN /usr/share/elasticsearch/bin/plugin -i lmenezes/elasticsearch-kopf/latest

# license and watcher
RUN /usr/share/elasticsearch/bin/plugin -i elasticsearch/license/latest
RUN /usr/share/elasticsearch/bin/plugin -i elasticsearch/watcher/latest
RUN rm /etc/elasticsearch/elasticsearch.yml
ADD elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# Create Index
RUN git clone https://github.com/royrusso/elasticsearch-sample-index.git && \
    service elasticsearch start && sleep 10 && \
    cd elasticsearch-sample-index && php elasticput.php

ADD startup.sh /usr/local/bin/startup.sh

CMD bash -C '/usr/local/bin/startup.sh';'zsh'

EXPOSE 9200

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
