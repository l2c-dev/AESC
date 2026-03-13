#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulacoes}"

SINGLE_DIR="$SIMS_BASE/xfoil/single_runs"
SWEEPS_DIR="$SIMS_BASE/xfoil/sweeps"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║               Ambiente de execução – XFOIL 🛩️ | Limpeza de simulações         ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "O que deseja limpar?"
echo " [1] 🧪 Remover um caso único"
echo " [2] 🌪️  Remover uma campanha de varredura"
echo " [0] 🔙 Voltar ao menu XFOIL"
echo ""
read -p "Digite a opção desejada: " MODO

case "$MODO" in
  1)
    BASE_DIR="$SINGLE_DIR"
    TIPO="caso único"
    ;;
  2)
    BASE_DIR="$SWEEPS_DIR"
    TIPO="campanha de varredura"
    ;;
  0)
    bash "$SCRIPT_DIR/menu_xfoil.sh"
    exit 0
    ;;
  *)
    echo "❌ Opção inválida."
    read -p "Pressione [Enter] para retornar..."
    bash "$SCRIPT_DIR/menu_xfoil.sh"
    exit 1
    ;;
esac

if [[ ! -d "$BASE_DIR" ]]; then
  echo "❌ Diretório não encontrado:"
  echo "   $BASE_DIR"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

mapfile -t ITENS < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

if [[ ${#ITENS[@]} -eq 0 ]]; then
  echo "⚠️  Nenhum item encontrado para limpeza."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 0
fi

echo ""
echo "📁 Itens disponíveis para remoção ($TIPO):"
echo ""
for i in "${!ITENS[@]}"; do
  echo " [$i] 📁 ${ITENS[$i]}"
done
echo " [${#ITENS[@]}] 🔙 Voltar ao menu XFOIL"
echo ""

read -p "Digite o número do item que deseja remover: " ESCOLHA

if [[ "$ESCOLHA" == "${#ITENS[@]}" ]]; then
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 0
fi

if ! [[ "$ESCOLHA" =~ ^[0-9]+$ ]] || (( ESCOLHA < 0 || ESCOLHA >= ${#ITENS[@]} )); then
  echo "❌ Opção inválida."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

ITEM="${ITENS[$ESCOLHA]}"
ITEM_DIR="$BASE_DIR/$ITEM"

echo ""
echo "⚠️  Confirma a remoção permanente do item abaixo?"
echo "   $ITEM_DIR"
read -p "Digite 'sim' para confirmar: " CONFIRMACAO

if [[ "$CONFIRMACAO" != "sim" ]]; then
  echo "✅ Operação cancelada."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 0
fi

rm -rf "$ITEM_DIR"

echo ""
echo "✅ Remoção concluída com sucesso."
echo "🗑️  Item removido:"
echo "   $ITEM_DIR"
echo ""

read -p "🔁 Deseja remover outro item? (s/n): " RESPOSTA
if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
  bash "$SCRIPT_DIR/limpar_simulacoes.sh"
else
  bash "$SCRIPT_DIR/menu_xfoil.sh"
fi
