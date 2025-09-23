#!/bin/bash

# Diretórios relativos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SIMULACOES_DIR="$ROOT_DIR/../simulacoes/simmsus"

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
