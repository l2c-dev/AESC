#!/usr/bin/env bash
set -euo pipefail

# AESC - Ferramenta de desenvolvimento
# Injeta o loader do env.sh logo após o shebang de scripts .sh, se ainda não houver.

LOADER_BLOCK='
# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────
'

usage() {
  echo "uso: $(basename "$0") <arquivo1.sh> [arquivo2.sh ...]"
  echo "     ou: find ... -name '*.sh' -print0 | xargs -0 $(basename "$0")"
}

inject_one() {
  local f="$1"
  [ -f "$f" ] || { echo "❌ não encontrado: $f"; return 1; }

  # Já tem o loader?
  if grep -q 'Carrega env.sh (mínimo e idempotente)' "$f"; then
    echo "↪︎ já tem loader: $f"
    return 0
  fi

  # Exige shebang na 1ª linha
  if ! head -n1 "$f" | grep -Eq '^#!'; then
    echo "⚠️  sem shebang na 1ª linha, pulando: $f"
    return 0
  fi

  cp -p "$f" "$f.bak"
  { head -n1 "$f"; printf "%s\n" "$LOADER_BLOCK"; tail -n +2 "$f"; } > "$f.tmp"
  mv "$f.tmp" "$f"
  chmod +x "$f"
  echo "✓ loader inserido: $f"
}

if [ "$#" -eq 0 ]; then
  usage; exit 1
fi

for f in "$@"; do
  inject_one "$f"
done
