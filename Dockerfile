
# Using Ubuntu because it's the most popular, which typically makes
# troubleshooting easier
FROM ubuntu:22.04

WORKDIR /minecraft-server

# Install dependencies
COPY packages-ubuntu.txt .
RUN apt-get update     \
 && apt-get upgrade -y \
 && apt-get install -y $(cat packages-ubuntu.txt)

COPY get-papermc.sh .
RUN ./get-papermc.sh

# lightweight profiler
COPY get-spark.sh .
RUN ./get-spark.sh

COPY entrypoint.sh .

RUN groupadd -r mcserver            \
 && useradd -r -g mcserver mcserver \
 && chown mcserver:mcserver --recursive /minecraft-server

USER mcserver:mcserver

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 25565/tcp
EXPOSE 25565/udp
