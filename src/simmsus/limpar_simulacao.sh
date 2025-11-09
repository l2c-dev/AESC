#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Caminho do script (usado para voltar ao menu no final)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# ─────────────────────────── Caminhos via env.sh (com fallback) ────────────────
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"

SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"
SIMULACOES_DIR="$SIMS_BASE/simmsus"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║        Ambiente de execução – SIMMSUS 🧲 | Limpeza de simulações             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verifica se o diretório existe
cd "$SIMULACOES_DIR" || {
  echo "❌ Diretório de simulações não encontrado: $SIMULACOES_DIR"
  read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 1
}

# Lista subpastas
mapfile -t PASTAS < <(find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort)

if [ ${#PASTAS[@]} -eq 0 ]; then
  echo "⚠️ Nenhuma pasta de simulação encontrada em $SIMULACOES_DIR."
  echo ""
  read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 0
fi

echo "🧹 Pastas de simulações encontradas:"
for i in "${!PASTAS[@]}"; do
  echo " [$i] 📁 ${PASTAS[$i]}"
done
echo " [${#PASTAS[@]}] 🔙 Voltar ao menu SIMMSUS"
echo ""

read -p "Digite o número da pasta que deseja limpar: " escolha

# Voltar
if [[ "$escolha" == "${#PASTAS[@]}" ]]; then
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 0
fi

# Verifica se é número válido
if ! [[ "$escolha" =~ ^[0-9]+$ ]] || (( escolha < 0 || escolha >= ${#PASTAS[@]} )); then
  echo "❌ Opção inválida. Retornando ao menu SIMMSUS..."
  sleep 1
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 1
fi

PASTA_ESCOLHIDA="${PASTAS[$escolha]}"
ABS_PATH="$SIMULACOES_DIR/$PASTA_ESCOLHIDA"

echo ""
echo "⚠️ Você está prestes a limpar a pasta:"
echo "📁 $ABS_PATH"
echo "❗ Todos os arquivos e subpastas serão apagados, exceto 'simconfig.dat'"
echo ""

read -p "Tem certeza que deseja continuar? (s/n): " confirmacao
if [[ "$confirmacao" != "s" ]]; then
  echo "❌ Operação cancelada. Retornando ao menu SIMMSUS..."
  sleep 1
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 0
fi

# Limpeza: apaga tudo exceto simconfig.dat
find "$ABS_PATH" -mindepth 1 ! -name "simconfig.dat" -exec rm -rf {} +

echo ""
echo "✅ Limpeza concluída em '$PASTA_ESCOLHIDA'."
echo ""
read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
bash "$SCRIPT_DIR/menu_simmsus.sh"
