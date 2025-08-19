FROM node:18-slim

WORKDIR /opt/genieacs

RUN apt-get update && apt-get install -y \
    unzip build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copia o zip local SEM GitHub
COPY ../genieacs-master.zip /tmp/genieacs.zip

# Extrai apenas o backend
RUN unzip /tmp/genieacs.zip -d /opt \
    && mv /opt/genieacs-master/* /opt/genieacs/ \
    && rm -rf /tmp/genieacs.zip /opt/genieacs-master

RUN npm install --legacy-peer-deps

ENV PATH="/opt/genieacs/bin:${PATH}"

CMD ["bash"]
