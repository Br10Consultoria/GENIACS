FROM node:18-slim AS build

WORKDIR /opt/genieacs

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      unzip \
      build-essential \
      python3 \
    && rm -rf /var/lib/apt/lists/*

COPY genieacs-master.zip /tmp/genieacs.zip
COPY genieacs-ui-overrides/ /tmp/genieacs-ui-overrides/

RUN unzip /tmp/genieacs.zip -d /tmp \
    && mv /tmp/genieacs-master/* /opt/genieacs/ \
    && if [ -d /tmp/genieacs-ui-overrides ]; then cp -a /tmp/genieacs-ui-overrides/. /opt/genieacs/; fi \
    && rm -rf /tmp/genieacs.zip /tmp/genieacs-master /tmp/genieacs-ui-overrides \
    && git init \
    && git config user.email "build@local" \
    && git config user.name "local-build" \
    && git add -A \
    && git commit -m "local build snapshot" \
    && npm ci --legacy-peer-deps \
    && npm run build \
    && npm prune --omit=dev \
    && npm cache clean --force \
    && rm -rf .git

FROM node:18-slim

ENV NODE_ENV=production \
    PATH="/opt/genieacs/bin:/opt/genieacs/dist/bin:${PATH}"

WORKDIR /opt/genieacs

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tini \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system genieacs \
    && useradd --system --gid genieacs --home-dir /opt/genieacs --shell /usr/sbin/nologin genieacs

COPY --from=build --chown=genieacs:genieacs /opt/genieacs /opt/genieacs

USER genieacs

EXPOSE 7547 7557 7567 3000

ENTRYPOINT ["tini", "--"]
CMD ["genieacs-ui"]
