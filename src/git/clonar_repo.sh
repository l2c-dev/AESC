#!/bin/bash
# Clonar repositório público do GitHub (HTTPS) para ../codigos/<repo>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEST_PADRAO="$(readlink -f "$ROOT_DIR/../codigos")"

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
  read -p "Pressione ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_git.sh"; exit 1
fi

read -p "🔗 URL HTTPS do repositório (ex.: https://github.com/usuario/repo.git): " URL
[[ -z "$URL" ]] && { echo "❌ URL vazia."; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_git.sh"; exit 1; }

echo "📁 Diretório de destino padrão: $DEST_PADRAO"
read -p "Deseja usar esse destino? [S/n]: " use_padrao
if [[ "$use_padrao" =~ ^[Nn]$ ]]; then
  read -p "Informe o diretório de destino: " DEST_ESC
  DEST_DIR="${DEST_ESC/#\~/$HOME}"
  DEST_DIR="$(readlink -f "$DEST_DIR")"
else
  DEST_DIR="$DEST_PADRAO"
fi

mkdir -p "$DEST_DIR" || { echo "❌ Falha ao criar/acessar $DEST_DIR"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_git.sh"; exit 1; }

cd "$DEST_DIR" || { echo "❌ Falha ao acessar $DEST_DIR"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_git.sh"; exit 1; }
echo ""
echo "⬇️  Clonando em: $DEST_DIR"
if ! git clone "$URL"; then
  echo "❌ Falha ao clonar."
  read -p "Pressione ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_git.sh"; exit 1
fi

REPO_NOME="$(basename -s .git "$URL")"
echo ""
echo "✅ Repositório clonado com sucesso!"
echo "📁 Pasta: $DEST_DIR/$REPO_NOME"

read -p "Pressione ENTER para retornar ao menu Git..."
bash "$SCRIPT_DIR/menu_git.sh"; exit 0
