#!/bin/bash
set -euo pipefail

# === НЕТРАННЕР ===
C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_NC='\033[0m'

log_jack_in() { echo -e "${C_CYAN}>_ [ВЗЛОМ ПОРТА]${C_NC} $1"; }
log_preem()   { echo -e "${C_GREEN}>_ [ВЫШАК]${C_NC} $1"; }
log_glitch()  { echo -e "${C_YELLOW}>_ [ГЛИТЧ]${C_NC} $1"; }
log_flatline(){ echo -e "${C_RED}>_ [ФЛЭТЛАЙН]${C_NC} $1"; exit 1; }

# === ЗАЩИТА: ТОЛЬКО ИЗ TG ===
if [[ -t 1 ]]; then
  log_flatline "Обновление можно запускать только через Telegram-бота, а не напрямую в терминале."
fi

# === ENV ===
BASE_DIR="/opt/n8n-install"
cd "$BASE_DIR"
set -a
source .env
set +a

# === TG ===
send_telegram() {
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_USER_ID}" \
    -d parse_mode="Markdown" \
    -d text="$1"
}

# === СТАРТ ===
send_telegram "🛠 *Начинаю обновление Kontent-Zavod...*"
log_jack_in "Проверка доступных обновлений..."

# === БЭКАП ===
log_jack_in "Создаю бэкап перед обновлением..."
./backup.sh

# === ОБНОВЛЕНИЕ N8N ===
log_jack_in "Обновляю n8n..."
docker compose pull n8n
docker compose build --no-cache n8n
docker compose up -d n8n

# === ОБНОВЛЕНИЕ POSTIZ ===
log_jack_in "Обновляю Postiz..."
docker compose pull postiz
docker compose up -d postiz

# === ОБНОВЛЕНИЕ SVM ===
log_jack_in "Обновляю Short Video Maker..."
docker compose pull short-video-maker
docker compose up -d short-video-maker

# === ОЧИСТКА МУСОРА ===
log_jack_in "Очищаю систему от старых образов..."
docker image prune -f
docker builder prune -f

# === ФИНАЛ ===
log_preem "Обновление завершено."
send_telegram "✅ *Обновление Kontent-Zavod завершено.*\nВсе сервисы перезапущены."
