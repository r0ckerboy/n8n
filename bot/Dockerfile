# === ЛЁГКИЙ АЛЬПИЙСКИЙ ОБРАЗ ===
FROM node:20-alpine

# === УСТАНОВКА ЗАВИСИМОСТЕЙ ===
RUN apk add --no-cache \
    bash \
    curl \
    docker-cli \
    coreutils

# === РАБОЧАЯ ДИРЕКТОРИЯ ===
WORKDIR /app

# === КОПИРУЕМ ФАЙЛЫ ===
COPY package*.json ./
RUN npm install --production

COPY bot.js ./

# === ЗАПУСК ===
CMD ["node", "bot.js"]
