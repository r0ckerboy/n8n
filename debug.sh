#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== ДИАГНОСТИКА N8N STACK ===${NC}\n"

# Проверка статуса контейнеров
echo -e "${YELLOW}1. Статус контейнеров:${NC}"
docker compose ps
echo ""

# Проверка логов n8n
echo -e "${YELLOW}2. Последние логи n8n:${NC}"
docker compose logs n8n --tail=20
echo ""

# Проверка подключения к PostgreSQL
echo -e "${YELLOW}3. Проверка PostgreSQL:${NC}"
docker compose exec postgres psql -U postiz-user -d postgres -c "\l" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}PostgreSQL работает${NC}"
else
    echo -e "${RED}Проблема с PostgreSQL${NC}"
fi
echo ""

# Проверка Redis
echo -e "${YELLOW}4. Проверка Redis:${NC}"
docker compose exec redis redis-cli ping 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Redis работает${NC}"
else
    echo -e "${RED}Проблема с Redis${NC}"
fi
echo ""

# Проверка Traefik роутинга
echo -e "${YELLOW}5. Проверка Traefik роутов:${NC}"
docker compose exec traefik wget -qO- http://localhost:8080/api/http/routers 2>/dev/null | grep -E "n8n|postiz|svm" | head -20
echo ""

# Проверка доступности n8n
echo -e "${YELLOW}6. Проверка доступности n8n внутри контейнера:${NC}"
docker compose exec n8n wget -qO- http://localhost:5678/healthz 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}n8n отвечает на запросы${NC}"
else
    echo -e "${RED}n8n не отвечает${NC}"
fi
echo ""

# Проверка DNS и сертификатов
echo -e "${YELLOW}7. Проверка сертификатов Let's Encrypt:${NC}"
if [ -f "./data/letsencrypt/acme.json" ]; then
    CERT_COUNT=$(grep -c "certificate" ./data/letsencrypt/acme.json 2>/dev/null)
    echo -e "Найдено сертификатов: $CERT_COUNT"
else
    echo -e "${RED}Файл acme.json не найден${NC}"
fi
echo ""

# Проверка переменных окружения
echo -e "${YELLOW}8. Проверка переменных окружения:${NC}"
if [ -f ".env" ]; then
    echo "BASE_DOMAIN=$(grep BASE_DOMAIN .env | cut -d'=' -f2)"
    echo "Проверьте, что домен правильный и DNS записи настроены"
else
    echo -e "${RED}.env файл не найден${NC}"
fi
echo ""

# Рекомендации
echo -e "${YELLOW}=== РЕКОМЕНДАЦИИ ===${NC}"
echo "1. Если n8n выдает 404, проверьте:"
echo "   - DNS записи указывают на ваш сервер"
echo "   - Порты 80 и 443 открыты в файрволле"
echo "   - Подождите 2-3 минуты после запуска для получения сертификатов"
echo ""
echo "2. Если не работает русская озвучка в Short Video Maker:"
echo "   - Проверьте PEXELS_API_KEY в .env файле"
echo "   - Убедитесь, что установлен полный образ (не tiny)"
echo ""
echo "3. Для перезапуска всего стека:"
echo "   docker compose down && docker compose up -d"
echo ""
echo "4. Для пересоздания с нуля:"
echo "   docker compose down -v && docker compose up -d"
