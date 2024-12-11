# Этап 1: Сборка приложения
FROM golang:1.22 AS builder

WORKDIR /app

# Копируем зависимости и скачиваем их
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь проект и собираем бинарник
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Этап 2: Создание минимального образа
FROM alpine:3.18

WORKDIR /root/

# Устанавливаем зависимости для SQLite
RUN apk add --no-cache sqlite

# Копируем бинарный файл из предыдущего этапа
COPY --from=builder /app/main .

# Копируем базу данных
COPY tracker.db /root/tracker.db

# Устанавливаем разрешения для выполнения файла
RUN chmod +x ./main

# Указываем команду по умолчанию
CMD ["./main"]

