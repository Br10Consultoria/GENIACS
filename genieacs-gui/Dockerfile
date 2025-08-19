FROM node:18-slim

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    unzip build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copia o mesmo zip local
COPY ../genieacs-master.zip /tmp/genieacs.zip

# Extrai apenas o GUI
RUN unzip /tmp/genieacs.zip -d /tmp \
    && mv /tmp/genieacs-master/gui/* /usr/src/app/ \
    && rm -rf /tmp/genieacs.zip /tmp/genieacs-master

RUN npm install --legacy-peer-deps && npm run build

EXPOSE 3000
CMD ["npm", "start"]
