FROM docker.elastic.co/elasticsearch/elasticsearch:8.12.2

USER elasticsearch

RUN echo "y" | bin/elasticsearch-plugin install discovery-ec2

EXPOSE 9200 9300