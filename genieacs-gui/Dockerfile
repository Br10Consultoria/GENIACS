FROM node:18-slim

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    unzip build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copia o zip local já no seu repositório
COPY ../genieacs-master.zip /tmp/genieacs.zip

# Extrai apenas o diretório do GUI
RUN unzip /tmp/genieacs.zip -d /opt \
    && mv /opt/genieacs-master/gui/* /usr/src/app/ \
    && rm -rf /tmp/genieacs.zip

# Instala dependências
RUN npm install && npm run build

EXPOSE 3000
CMD ["npm", "start"]
