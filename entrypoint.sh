#!/bin/bash
set -e

# Установка гемов (только если не установлены)
bundle check || bundle install

# Подготовка базы данных
echo "🔧 Подготовка базы..."
bundle exec rails db:prepare

# Прогон тестов — только если не production
if [ "$RAILS_ENV" != "production" ]; then
  echo "🧪 Прогон тестов..."
  bundle exec rspec --format documentation
fi

# Запуск сервера
echo "🚀 Запуск сервера..."
exec "$@"
