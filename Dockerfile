# Stage 1: Build Stage
FROM node:18 AS build

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем файлы package.json и package-lock.json для установки зависимостей
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем остальные файлы проекта
COPY . .

# Собираем Nuxt-приложение
RUN npm run build

# Stage 2: Production Stage
FROM node:18 AS production

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем зависимости из build stage
COPY --from=build /app/node_modules ./node_modules

# Копируем только необходимые файлы для запуска
COPY --from=build /app/.output ./.output

# Задаем порт для Nuxt
ENV PORT=3000
EXPOSE 3000

# Запуск Nuxt-приложения в продакшене
CMD ["node", ".output/server/index.mjs"]