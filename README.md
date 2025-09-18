```markdown
# KONTENT-ZAVOD 🌆  
**Один скрипт — весь стек: n8n + Postiz + Short Video Maker + Telegram-бот + бэкапы.**

> «Не теряйся в Сети, чумба.»  
> — *fixer из Night City*

---

### ⚡ УСТАНОВКА ОДНОЙ КОМАНДОЙ
```bash
sudo bash <(curl -s https://raw.githubusercontent.com/r0ckerboy/n8n/main/install.sh)
```

---

### 🔧 ЧТО СТАВИТ
| Сервис | Домен | Описание |
|--------|-------|----------|
| **n8n** | `https://n8n.<domain>` | Автоматизация workflow |
| **Postiz** | `https://postiz.<domain>` | Планировщик постов (GitRoom) |
| **Short Video Maker** | `https://svm.<domain>` | Генерация Shorts из картинок + TTS |
| **Traefik** | `https://traefik.<domain>` | Панель управления SSL и роутами |
| **Telegram-бот** | `@your_bot` | `/status`, `/logs`, `/backup`, `/update` |
| **PostgreSQL + Redis** | internal | База и кэш |

---

### 🤖 КОМАНДЫ TELEGRAM-БОТА
| Команда | Описание |
|---------|----------|
| `/status` | Аптайм и статус контейнеров |
| `/logs <service>` | Последние 50 строк логов |
| `/backup` | Создать и отправить бэкап в Telegram |
| `/update` | Обновить n8n, Postiz, SVM |

---

### 📅 АВТОБЭКАПЫ
- Каждый день в **02:00**
- Архив: `.env` + workflows + credentials + дамп БД
- Отправляется в Telegram и **удаляется с сервера**

---

### 🔒 БЕЗОПАСНОСТЬ
- SSL от **Let's Encrypt** (авто)
- Архивы **не хранятся** на сервере
- Бот работает **только с твоим Telegram ID**

---

### ⚙ ТРЕБОВАНИЯ
- **Ubuntu 22.04** (чистая)
- **Домен** с A-записью на IP сервера
- **Права root**

---

### 🧬 ОБНОВЛЕНИЕ
```bash
# Через Telegram-бота:
/update

# Вручную:
cd /opt/n8n-stack && ./update.sh
```

---

### 📂 СТРУКТУРА ПОСЛЕ УСТАНОВКИ
```
/opt/n8n-stack/
├── docker-compose.yml
├── install.sh
├── backup.sh
├── update.sh
├── .env
├── data/
│   ├── n8n/
│   ├── postgres/
│   ├── redis/
│   ├── videos/
│   └── backups/
├── n8n/Dockerfile
└── bot/
    ├── bot.js
    └── Dockerfile
```

---

### 🧹 УДАЛЕНИЕ
```bash
cd /opt/n8n-stack
docker compose down
rm -rf /opt/n8n-stack
```

---

### 📞 ПОДДЕРЖКА
Если что-то пошло по факапу — пиши в Telegram-бота `/status` и смотри логи.

---

> «Контент не ждёт. Запускай завод.»  
> — *r0ckerboy, 2077*
```
