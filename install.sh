#!/bin/bash
set -e

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

# === ДОСТУП ===
if (( EUID != 0 )); then
  log_flatline "Доступ только для корпо-крыс. Нужны права root."
fi

clear
echo -e "${C_CYAN}"
cat << "EOF"


██████╗  ██████╗ ███████╗███████╗███╗   ██╗ ██████╗   ██████╗ ██╗   ██╗
╚════██╗██╔═████╗╚════██║╚════██║████╗  ██║██╔════╝   ██╔══██╗██║   ██║
 █████╔╝██║██╔██║    ██╔╝    ██╔╝██╔██╗ ██║██║        ██████╔╝██║   ██║
██╔═══╝ ████╔╝██║   ██╔╝    ██╔╝ ██║╚██╗██║██║        ██╔══██╗██║   ██║
███████╗╚██████╔╝   ██║     ██║  ██║ ╚████║╚██████╗██╗██║  ██║╚██████╔╝
╚══════╝ ╚═════╝    ╚═╝     ╚═╝  ╚═╝  ╚═══╝ ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝ 

> [СИСТЕМА ОНЛАЙН]: K O H T E N T - З A В O D
> [СТАТУС]: ЗАГРУЗКА... // NIGHT CITY v2.0.77
EOF
echo -e "${C_NC}"
echo "----------------------------------------------------"

# === ИМПЛАНТЫ ===
log_jack_in "Сканирую систему на необходимое железо..."
apt-get update -y
apt-get install -y git curl zip unzip openssl

# === DOCKER ===
if ! command -v docker &>/dev/null; then
  log_jack_in "Устанавливаю Docker-имплант..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
fi

if ! command -v docker compose &>/dev/null; then
  log_jack_in "Устанавливаю Docker-Compose чип..."
  curl -sSL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# === ЗАГРУЗКА ЧЕРТЕЖЕЙ ===
INSTALL_DIR="/opt/n8n-stack"
if [ -d "$INSTALL_DIR" ]; then
  log_glitch "Обнаружены остаточные данные. Зачищаю..."
  rm -rf "$INSTALL_DIR"
fi
log_jack_in "Качаю чертежи из Сети..."
git clone https://github.com/r0ckerboy/n8n.git "$INSTALL_DIR"
cd "$INSTALL_DIR"

# === ВВОД ДАННЫХ ===
log_jack_in "Фиксер требует твои данные для этого дельца:"
read -p "- Твой ДОМЕН (e.g., example.com): " BASE_DOMAIN
read -p "- Мыло для LETSENCRYPT (для шифровки канала): " LETSENCRYPT_EMAIL
read -sp "- Пароль от хранилища данных Postgres: " POSTGRES_PASSWORD && echo
read -p "- Telegram Bot Token: " TELEGRAM_BOT_TOKEN
read -p "- Telegram ID: " TELEGRAM_USER_ID
read -p "- Pexels API Key: " PEXELS_API_KEY
read -p "- Google Client ID (можно пропустить): " GOOGLE_CLIENT_ID
read -p "- Google Client Secret (можно пропустить): " GOOGLE_CLIENT_SECRET

# === КЛЮЧ ШИФРОВАНИЯ ===
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
log_preem "Сгенерирован ключ шифрования AES-256."

# === .env ===
cp .env.template .env
sed -i "s|BASE_DOMAIN=.*|BASE_DOMAIN=${BASE_DOMAIN}|" .env
sed -i "s|LETSENCRYPT_EMAIL=.*|LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}|" .env
sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PASSWORD}|" .env
sed -i "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}|" .env
sed -i "s|TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}|" .env
sed -i "s|TELEGRAM_USER_ID=.*|TELEGRAM_USER_ID=${TELEGRAM_USER_ID}|" .env
sed -i "s|PEXELS_API_KEY=.*|PEXELS_API_KEY=${PEXELS_API_KEY}|" .env
sed -i "s|GOOGLE_CLIENT_ID=.*|GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}|" .env
sed -i "s|GOOGLE_CLIENT_SECRET=.*|GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}|" .env

# === ДИРЕКТОРИИ ===
mkdir -p data/{postgres,redis,n8n,letsencrypt,videos,postiz-uploads,backups}
touch data/letsencrypt/acme.json
chmod 600 data/letsencrypt/acme.json

# === СБОРКА И ЗАПУСК ===
log_jack_in "Компилирую кастомного демона n8n..."
docker compose build
log_jack_in "Пробуждаю демонов..."
docker compose up -d

# === КРОН ===
(crontab -l 2>/dev/null; echo "0 2 * * * cd $INSTALL_DIR && ./backup.sh >> /var/log/backup.log 2>&1") | crontab -

# === ФИНАЛ ===
echo "----------------------------------------------------"
log_preem "СИСТЕМА ОНЛАЙН. Дельце сделано."
echo -e " > n8n: ${C_YELLOW}https://n8n.${BASE_DOMAIN}${C_NC}"
echo -e " > Postiz: ${C_YELLOW}https://postiz.${BASE_DOMAIN}${C_NC}"
echo -e " > Short Video Maker: ${C_YELLOW}https://svm.${BASE_DOMAIN}${C_NC}"
echo -e " > Traefik: ${C_YELLOW}https://traefik.${BASE_DOMAIN}${C_NC}"
echo ""
log_jack_in "Дай демонам пару минут на калибровку и установку защищённого соединения."
echo -e "${C_GREEN}Не теряйся в Сети, чумба.${C_NC}"
