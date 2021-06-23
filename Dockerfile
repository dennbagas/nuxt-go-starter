# Build and bundle the Vue.js frontend 
FROM node:14-alpine AS vue-build
WORKDIR /build/app

COPY frontend/package*.json ./
RUN npm i -g npm
RUN npm ci

COPY frontend/ .
RUN npm run generate

# Build the Go server backend
FROM golang:1.16-alpine as go-build

WORKDIR /build/src/server

RUN apk update && apk add git gcc musl-dev

COPY backend/*.go ./
COPY go.mod ./
COPY go.sum ./

ENV GO111MODULE=on
# Disabling cgo results in a fully static binary that can run without C libs
RUN CGO_ENABLED=0 GOOS=linux go build -o backend

# Assemble the server binary and Vue bundle into a single app
FROM alpine
WORKDIR /app/runtime

COPY --from=vue-build /build/dist ../dist/
COPY --from=go-build /build/src/server/backend ./backend

ENV PORT 4000
EXPOSE 4000
CMD ["/app/runtime/backend"]
