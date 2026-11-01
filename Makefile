DOCKER_COMPOSE_BASE = docker compose --project-directory "$(CURDIR)"
include makefiles/compose.mk
DOCKER_COMPOSE = docker compose --project-directory "$(CURDIR)" $(COMPOSE_FLAGS)
DOCKER ?= docker
NET = jaeger-net

-include .env
export
include makefiles/versions.mk

up: active-check init
	$(DOCKER_COMPOSE) up -d

init: network

network:
	@if $(DOCKER) network inspect $(NET) >/dev/null 2>&1; then \
		echo "network $(NET) already exists"; \
	else \
		$(DOCKER) network create $(NET) --opt com.docker.network.driver.mtu=1376; \
	fi

down:
	$(DOCKER_COMPOSE) down

logs:
	$(DOCKER_COMPOSE) logs -f

.PHONY: up down logs init network

.PHONY: versions config-check
versions:
	@$(foreach v,$(VERSION_VARS),printf '%s=%s\n' '$(v)' '$($(v))';)
config-check:
	$(DOCKER_COMPOSE) --env-file /dev/null config --quiet --no-env-resolution

# Read-only validation of every tracked Compose combination, without runtime secrets.
.PHONY: compose-layout-check
compose-layout-check:
	$(DOCKER_COMPOSE_BASE) --env-file /dev/null -f compose/docker-compose.yml --profile '*' config --no-interpolate --no-env-resolution --quiet

check: compose-layout-check

.PHONY: active-check deploy
active-check:
	@test ! -e .retired || { echo "This stack has been retired" >&2; exit 1; }

deploy: active-check
	$(MAKE) up

check: config-check

.PHONY: ci-deploy
ci-deploy:
	python3 scripts/ci-deploy.py
