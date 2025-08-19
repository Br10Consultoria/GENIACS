FROM node:18-slim

WORKDIR /opt/genieacs

RUN apt-get update && apt-get install -y \
    unzip build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copia o código local (sem GitHub)
COPY ../genieacs-master.zip /tmp/genieacs.zip

# Extrai dentro do container
RUN unzip /tmp/genieacs.zip -d /opt \
    && mv /opt/genieacs-master/* /opt/genieacs/ \
    && rm /tmp/genieacs.zip

# Instala dependências
RUN npm install

ENV PATH="/opt/genieacs/bin:${PATH}"

CMD ["bash"]
