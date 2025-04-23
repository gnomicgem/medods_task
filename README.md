# Сервис выдачи и обновления токенов аутентификации 

- [Основные возможности](#основные-возможности)
- [Технологии](#технологии)
- [Установка](#установка)
- [API Endpoints](#api-endpoints)

Реализуется два REST маршрута:

1. /auth/token — выдает пару Access и Refresh токенов для пользователя с указанным идентификатором (GUID) в параметре запроса.
2. /auth/refresh — выполняет Refresh операцию для пары Access и Refresh токенов.

## Основные возможности

- Access токен:

  - Тип: JWT.

  - Алгоритм: SHA512.

  - Не хранится в базе данных.

- Refresh токен:

  - Формат передачи: Base64.

  - Хранится в базе данных как bcrypt хэш.

  - Защищен от изменения на стороне клиента и попыток повторного использования.

- Связь токенов:

  - Access и Refresh токены обоюдно связаны.

  - Refresh операцию для Access токена можно выполнить только тем Refresh токеном, который был выдан вместе с ним.

- Информация о клиенте:

  - Payload токенов содержит сведения о IP-адресе клиента, которому токен был выдан.

- Изменение IP:

  - Если IP-адрес изменился, при Refresh операции отправляется предупреждающее email-сообщение пользователю.

## Технологии

- Ruby (версия 3.4.1)
- Ruby on Rails (версия 8.0.2)
- JWT
- PostgreSQL

## Установка

Клонируйте репозиторий:

```
git clone https://github.com/gnomicgem/medods_task.git
cd medods_task
```

Соберите и запустите контейнеры с помощью Docker Compose:

```
docker-compose up
```

Эта команда выполнит:

- Сборку и запуск контейнеров
- Создание базы данных и миграци
- Тестирование RSpec
- Запуск сервера

Чтобы остановить контейнеры:

```
docker-compose down
```

## API Endpoints

Доступно по адресу http://localhost:3000

### POST /auth/token

#### Request

Headers: Content-Type: application/json

Example Body:

```
{
  "auth": {
    "user_guid": "123e4567-e89b-12d3-a456-426614174000"
  }
}
```

#### Response

Success (200):

```
{
  "access_token": "eyJhbGciOiJIUzUxMiJ9.eyJndWlkIjoiMTIzZTQ1NjctZTg5Yi0xMmQzLWE0NTYtNDI2NjE0MTc0MDAwIiwiaXAiOiIxMjcuMC4wLjEiLCJqdGkiOiI5YzA2OGI0Mi1kODViLTRjMmMtYjkxZC04ODM2ZGQwNTVmMTkiLCJleHAiOjE3NDUzOTg1MzF9.14cfGnVMOsMDEHMiiv9uv_ixXmiaRou8NzsUboEuGmchWLctXwU9Y34YyiWVE5RI1UuTt-Za_FHlmsredPeFQA",
  "refresh_token": "s79qdH_N-ngy1OvR77B5vbeeeyWKJLGPPwtiumVaL00RFgWN7It4XW_NXuRyi5k7cItWDJSBA2u3xm_63yXQkA"
}
```

### POST /auth/refresh

#### Request

Headers: Content-Type: application/json

Example Body:

```
{
  "auth": {
    "access_token": "eyJhbGciOiJIUzUxMiJ9.eyJndWlkIjoiMTIzZTQ1NjctZTg5Yi0xMmQzLWE0NTYtNDI2NjE0MTc0MDAwIiwiaXAiOiIxMjcuMC4wLjEiLCJqdGkiOiI5YzA2OGI0Mi1kODViLTRjMmMtYjkxZC04ODM2ZGQwNTVmMTkiLCJleHAiOjE3NDUzOTg1MzF9.14cfGnVMOsMDEHMiiv9uv_ixXmiaRou8NzsUboEuGmchWLctXwU9Y34YyiWVE5RI1UuTt-Za_FHlmsredPeFQA",
    "refresh_token": "s79qdH_N-ngy1OvR77B5vbeeeyWKJLGPPwtiumVaL00RFgWN7It4XW_NXuRyi5k7cItWDJSBA2u3xm_63yXQkA"
  }
}
```

#### Response

Success (200):

```
{
  "access_token": "eyJhbGciOiJIUzUxMiJ9.eyJndWlkIjoiMTIzZTQ1NjctZTg5Yi0xMmQzLWE0NTYtNDI2NjE0MTc0MDAwIiwiaXAiOiIxMjcuMC4wLjEiLCJqdGkiOiI2NTAxNDYxOS0wOTg5LTQxYTItYTk3MS05MjdlNGRkOGIzOTkiLCJleHAiOjE3NDUzOTg5MzZ9.Vkjxa3OsKbSVnb8Aia4H3O773TC1m2L_1g3BH2yp0DUjkU-TXokbTszSzDAluP2bwl7iJVOZRcc6S5dMMZ2n_g",
  "refresh_token": "BLk6DiJrKCRzB30LVQCCvjVQqcqta-LefrI6K1_jO2Og8OuduMcf7h1ywGDbB5cOZCncHl-iqVdKOfhcRgK7jg"
}
```

Unauthorized (401):

```
{
   "error": "Refresh token already used"
}
```