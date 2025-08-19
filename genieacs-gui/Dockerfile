FROM node:18-slim

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    git build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --branch v1.2.13 https://github.com/genieacs/genieacs-gui.git .

RUN npm install && npm run build

EXPOSE 3000
CMD ["npm", "start"]