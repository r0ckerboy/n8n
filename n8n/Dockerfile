# === БАЗОВЫЙ ОБРАЗ: ALPINE LINUX ===
FROM n8nio/n8n:latest

# === ПЕРЕКЛЮЧАЕМСЯ НА ROOT ===
USER root

# === ОБНОВЛЯЕМ РЕПОЗИТОРИИ И УСТАНАВЛИВАЕМ ЗАВИСИМОСТИ ===
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
    bash \
    curl \
    git \
    ffmpeg \
    docker-cli \
    zip \
    unzip \
    openssl \
    yt-dlp

# === СОЗДАЁМ ГРУППУ DOCKER ===
ARG DOCKER_GID=999
RUN addgroup -g ${DOCKER_GID} docker || addgroup -S docker && \
    adduser node docker || true

# === УСТАНАВЛИВАЕМ NPM-ПАКЕТЫ ===
RUN npm config set fund false && npm config set audit false && \
    npm install -g \
    axios \
    node-fetch \
    form-data \
    moment \
    date-fns \
    lodash \
    fs-extra \
    csv-parser \
    xml2js \
    js-yaml \
    xlsx \
    jsonwebtoken \
    simple-oauth2 \
    uuid \
    openai \
    @tensorflow/tfjs-node \
    langchain \
    node-telegram-bot-api \
    discord.js \
    vk-io \
    fluent-ffmpeg \
    google-tts-api \
    node-wav \
    mongoose \
    ioredis \
    bcrypt \
    validator \
    joi \
    winston \
    dotenv \
    adm-zip \
    archiver

# === ВОЗВРАЩАЕМ ПОЛЬЗОВАТЕЛЯ NODE ===
USER node

# === КОНЕЦ ===
CMD ["n8n", "start"]
