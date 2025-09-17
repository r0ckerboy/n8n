#!/usr/bin/env node
// ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗████████╗
// ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║╚══██╔══╝
//    ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║   ██║
//    ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║   ██║
//    ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║   ██║
//    ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝
//
// >_ [СИСТЕМА]: NIGHT CITY ADMIN BOT v2.0.77
// >_ [СТАТУС]: ONLINE / ПОДКЛЮЧЁН К Docker Socket
// >_ [ПРОТОКОЛ]: Telegram API / Только указанный USER_ID

const TelegramBot = require('node-telegram-bot-api');
const { exec, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// === ENV ===
const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const USER_ID = process.env.TELEGRAM_USER_ID;
const DOCKER_SOCK = process.env.DOCKER_SOCKET_PATH || '/var/run/docker.sock';

if (!TOKEN || !USER_ID) {
  console.error('> _ [ФЛЭТЛАЙН] Отсутствуют TELEGRAM_BOT_TOKEN или TELEGRAM_USER_ID');
  process.exit(1);
}

const bot = new TelegramBot(TOKEN, { polling: true });

// === УТИЛИТЫ ===
const send = (txt) => bot.sendMessage(USER_ID, txt, { parse_mode: 'Markdown' });
const isAuthorized = (msg) => String(msg.chat.id) === String(USER_ID);

// === КОМАНДЫ ===
bot.onText(/\/start/, (msg) => {
  if (!isAuthorized(msg)) return;
  send(`🤖 *NIGHT CITY ADMIN BOT*
Доступные команды:
/status — аптайм и контейнеры
/logs <сервис> — логи контейнера
/backup — запустить бэкап
/update — обновить n8n + Postiz + SVM`);
});

bot.onText(/\/status/, (msg) => {
  if (!isAuthorized(msg)) return;
  try {
    const uptime = execSync('uptime -p').toString().trim();
    const containers = execSync('docker ps --format "✅ {{.Names}} ({{.Status}})"').toString().trim();
    send(`⏱ *Аптайм*: ${uptime}\n\n📦 *Контейнеры*:\n${containers}`);
  } catch (e) {
    send('❌ Ошибка при получении статуса');
  }
});

bot.onText(/\/logs (.+)/, (msg, match) => {
  if (!isAuthorized(msg)) return;
  const service = match[1].trim();
  exec(`docker logs --tail=50 ${service}`, (err, stdout, stderr) => {
    if (err) return send(`❌ Не удалось получить логи \`${service}\``);
    const out = (stdout || stderr).slice(-3500);
    send(`📝 *Логи ${service}*:\n\`\`\`\n${out}\n\`\`\``);
  });
});

bot.onText(/\/backup/, (msg) => {
  if (!isAuthorized(msg)) return;
  send('📦 Запускаю бэкап...');
  exec('/bin/bash /opt/n8n-install/backup.sh', (err, stdout, stderr) => {
    if (err) return send('❌ Ошибка бэкапа');
    send('✅ Бэкап завершён. Архив отправлен выше.');
  });
});

bot.onText(/\/update/, (msg) => {
  if (!isAuthorized(msg)) return;
  send('🔄 Начинаю обновление стека...');
  exec('/bin/bash /opt/n8n-install/update.sh', (err, stdout, stderr) => {
    if (err) return send('❌ Ошибка обновления');
    send(`✅ Обновление завершено:\n\`\`\`\n${stdout.slice(-1000)}\n\`\`\``);
  });
});

// === ИНИЦИАЛИЗАЦИЯ ===
console.log('> _ [СИСТЕМА] NIGHT CITY BOT ONLINE');
send('> _ [СИСТЕМА] Бот подключён к Docker Socket и готов к работе.');
