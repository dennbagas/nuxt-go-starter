# Used by `image`, `push` & `deploy` targets, override as required
IMAGE_REG ?= docker.io
IMAGE_REPO ?= dennbagas/vuego
IMAGE_TAG ?= latest

# Don't change
SPA_DIR := frontend
SRC_DIR := backend
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
GOPATH := $(shell go env GOPATH)

.PHONY: help image run clean watch-server watch-spa .EXPORT_ALL_VARIABLES
.DEFAULT_GOAL := help

help:  ## 💬 This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

image:  ## 🔨 Build container image from Dockerfile 
	docker build . \
	--tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

run: $(SPA_DIR)/node_modules  ## 🏃 Run BOTH components locally using Vue CLI and Go server backend
	cd $(SRC_DIR); go run main.go routes.go &
	cd $(SPA_DIR); npm run dev

watch-server:  ## 👀 Run API server with hot reload file watcher, needs cosmtrek/air
	cd $(SRC_DIR); ${GOPATH}/bin/air

watch-spa: $(SPA_DIR)/node_modules  ## 👀 Run frontend SPA with hot reload file watcher
	cd $(SPA_DIR); npm run dev

clean:  ## 🧹 Clean up project
	rm -rf $(SPA_DIR)/dist
	rm -rf $(SPA_DIR)/node_modules
	rm -rf $(SRC_DIR)/server_tests.txt
	rm -rf $(SPA_DIR)/test*.html
	rm -rf $(SPA_DIR)/coverage
	rm -rf $(REPO_DIR)/bin

# ============================================================================

$(SPA_DIR)/node_modules: $(SPA_DIR)/package.json
	cd $(SPA_DIR); npm install --silent
	touch -m $(SPA_DIR)/node_modules

$(SPA_DIR)/package.json: 
	@echo "package.json was modified"
