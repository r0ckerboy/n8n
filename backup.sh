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

# === ПЕРЕМЕННЫЕ ===
BASE_DIR="/opt/n8n-install"
BACKUP_DIR="$BASE_DIR/backups"
EXPORT_DIR="$BASE_DIR/export_temp"
ARCHIVE_NAME="kontent-zavod-backup-$(date +%Y-%m-%d_%H-%M-%S).zip"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
ENV_FILE="$BASE_DIR/.env"

# === ЗАГРУЗКА ENV ===
set -a
source "$ENV_FILE"
set +a

# === TELEGRAM ===
send_telegram() {
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_USER_ID}" \
    -F document=@"$1" \
    -F caption="$2"
}

# === СТАРТ ===
log_jack_in "Запускаю архиватор контента..."
mkdir -p "$BACKUP_DIR" "$EXPORT_DIR"

# === ЭКСПОРТ N8N ===
log_jack_in "Экспортирую workflows и credentials из n8n..."
docker exec n8n n8n export:workflow --all --separate --output=/tmp/export_dir || true
docker exec n8n n8n export:credentials --all --output=/tmp/creds.json || true
docker cp n8n:/tmp/export_dir "$EXPORT_DIR/workflows"
docker cp n8n:/tmp/creds.json "$EXPORT_DIR/credentials.json" || echo '{}' > "$EXPORT_DIR/credentials.json"

# === ДАМП POSTGRES ===
log_jack_in "Создаю дамп базы..."
docker exec postgres pg_dump -U "${POSTGRES_USER:-admin}" -d "${POSTGRES_DB:-main_db}" > "$EXPORT_DIR/db.sql"

# === АРХИВ ===
log_jack_in "Сжимаю данные в архив..."
zip -jrq "$ARCHIVE_PATH" "$EXPORT_DIR" .env
log_preem "Архив создан: $ARCHIVE_PATH"

# === ОТПРАВКА В TG ===
send_telegram "$ARCHIVE_PATH" "✅ Бэкап Kontent-Zavod готов ($(date +%d.%m.%Y %H:%M))"

# === ОЧИСТКА ===
rm -rf "$EXPORT_DIR"
find "$BACKUP_DIR" -name "*.zip" -mtime +7 -delete

log_preem "Архиватор завершил работу. Данные отправлены в Telegram и удалены с сервера."
