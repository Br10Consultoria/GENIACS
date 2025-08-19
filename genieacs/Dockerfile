FROM node:18-slim

WORKDIR /opt/genieacs

RUN apt-get update && apt-get install -y \
    git build-essential python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --branch v1.2.13 https://github.com/genieacs/genieacs.git .

RUN npm install

ENV PATH="/opt/genieacs/bin:${PATH}"

CMD ["bash"]
