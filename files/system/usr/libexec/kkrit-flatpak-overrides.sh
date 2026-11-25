#!/usr/bin/env bash
# KKRIT OS: системные override-ы для Flatpak-приложений.
# Запускается при каждой загрузке (идемпотентно): правит /var/lib/flatpak/overrides,
# который не входит в образ и не может быть запечён на этапе сборки.
set -euo pipefail

command -v flatpak >/dev/null 2>&1 || exit 0

# VS Code: полный доступ к файловой системе хоста.
# host      — /home, /media, /opt, /run/media, /srv (+ /run/host)
# host-os   — системные каталоги (/usr, /boot, ...), только чтение
# host-etc  — /etc, чтение и запись
flatpak override --system \
  --filesystem=host \
  --filesystem=host-os \
  --filesystem=host-etc \
  com.visualstudio.code
