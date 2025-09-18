#!/bin/bash
set -e

# === CYBERPUNK BOOTSTRAP ===
# Устанавливает curl и запускает install.sh

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_NC='\033[0m'

echo -e "${C_CYAN}>_ [BOOTSTRAP] Проверяю наличие curl...${C_NC}"

if ! command -v curl &>/dev/null; then
  echo -e "${C_CYAN}>_ [ВЗЛОМ ПОРТА] Устанавливаю curl...${C_NC}"
  sudo apt-get update -y >/dev/null 2>&1
  sudo apt-get install -y curl >/dev/null 2>&1
fi

echo -e "${C_GREEN}>_ [ВЫШАК] Качаю и запускаю install.sh...${C_NC}"

# Скачиваем и запускаем
curl -s https://raw.githubusercontent.com/r0ckerboy/n8n/main/install.sh -o /tmp/kontent-install.sh
chmod +x /tmp/kontent-install.sh
sudo /tmp/kontent-install.sh
