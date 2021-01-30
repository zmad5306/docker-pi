FROM debian:buster

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ffmpeg \
    sudo \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
#RUN apk update
#RUN apk update && apk add wget
#RUN apk --no-cache add ffmpeg
RUN mkdir /vids
VOLUME /vids
COPY run.sh entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
