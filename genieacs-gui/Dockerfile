FROM debian:12.10-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=18

RUN apt-get update && apt-get install -y \
    curl gnupg build-essential ca-certificates git unzip

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

WORKDIR /opt

ADD https://github.com/genieacs/genieacs-gui/archive/refs/tags/v1.2.9.zip /tmp/gui.zip
RUN unzip /tmp/gui.zip -d /opt && mv /opt/genieacs-gui-1.2.9 /opt/genieacs-gui && rm /tmp/gui.zip

WORKDIR /opt/genieacs-gui

RUN npm install
RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
