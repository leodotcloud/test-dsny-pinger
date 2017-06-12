FROM leodotcloud/golang:1.7
RUN apt-get update \
    && apt-get install -y gawk
COPY pinger.sh start.sh /usr/bin/
CMD ["start.sh"]
