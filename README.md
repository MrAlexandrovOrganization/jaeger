# Jaeger

Версия образа задаётся в `versions.mk`; `make versions` показывает её.
Make экспортирует значение в Compose. CI вызывает `make config-check`.

- `make config-check` — валидация Compose.
- `make up` / `make down` / `make logs` — управление стеком.

При проверках используйте синтетические настройки и checkout без `.env`.
Запускайте Compose через Make, чтобы не дублировать версию образа.

## Container names

Compose uses explicit service names without replica numbers. Set
`CONTAINER_NAME_PREFIX` (for example `dev-`) for an additional local or CI stack
on the same Docker host. Keep Compose project/service labels and volume names
unchanged; clients address services or explicit network aliases.
