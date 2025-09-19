-- Создаем базу данных для n8n если не существует
SELECT 'CREATE DATABASE n8n'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n')\gexec

-- Даем права пользователю
GRANT ALL PRIVILEGES ON DATABASE n8n TO "postiz-user";
GRANT ALL PRIVILEGES ON DATABASE "postiz-db-local" TO "postiz-user";

-- Подключаемся к базе n8n
\c n8n;

-- Создаем схему если не существует
CREATE SCHEMA IF NOT EXISTS public;
GRANT ALL ON SCHEMA public TO "postiz-user";
GRANT ALL ON SCHEMA public TO public;
