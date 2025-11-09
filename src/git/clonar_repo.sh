#!/bin/bash
# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do [ -f "$_aesc_env" ] && . "$_aesc_env" && break; done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Clonar repositório público do GitHub (HTTPS) para AESC_CODES_DIR
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Base de códigos via env.sh, com fallback
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
[[ -d "$AESC_ROOT/codigos" && ! -d "$CODES_BASE" ]] && CODES_BASE="$AESC_ROOT/codigos"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                 Git 🧰 | Clonar repositório do GitHub (HTTPS)                ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "❌ git não encontrado. Instale-o (ex.: sudo apt install -y git)."
  read -r -p "Pressione ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_git.sh"
fi

read -r -p "🔗 URL HTTPS do repositório (ex.: https://github.com/usuario/repo.git): " URL
[[ -z "$URL" ]] && { echo "❌ URL vazia."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }

echo "📁 Diretório de destino padrão: $CODES_BASE"
read -r -p "Deseja usar esse destino? [S/n]: " use_padrao
if [[ "$use_padrao" =~ ^[Nn]$ ]]; then
  read -r -p "Informe o diretório de destino: " DEST_ESC
  DEST_DIR="${DEST_ESC/#\~/$HOME}"
  DEST_DIR="$(readlink -f "$DEST_DIR")"
else
  DEST_DIR="$CODES_BASE"
fi

mkdir -p "$DEST_DIR" || { echo "❌ Falha ao criar/acessar $DEST_DIR"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }

cd "$DEST_DIR" || { echo "❌ Falha ao acessar $DEST_DIR"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }
echo ""
echo "⬇️  Clonando em: $DEST_DIR"
if ! git clone "$URL"; then
  echo "❌ Falha ao clonar."
  read -r -p "Pressione ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_git.sh"
fi

REPO_NOME="$(basename -s .git "$URL")"
echo ""
echo "✅ Repositório clonado com sucesso!"
echo "📁 Pasta: $DEST_DIR/$REPO_NOME"

read -r -p "Pressione ENTER para retornar ao menu Git..." _
exec bash "$SCRIPT_DIR/menu_git.sh"
