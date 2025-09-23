#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/octave")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                 Ambiente de execução – Octave 📉 | Limpar simulação          ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$SIM_DIR" ]]; then
  echo "❌ Diretório de simulações Octave não encontrado: $SIM_DIR"
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1
fi

cd "$SIM_DIR" || { echo "❌ Falha ao acessar $SIM_DIR"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1; }

mapfile -t PASTAS < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)
if [[ ${#PASTAS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhuma pasta de simulação encontrada."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 0
fi

echo "🧹 Pastas de simulações encontradas:"
for i in "${!PASTAS[@]}"; do echo " [$i] 📁 ${PASTAS[$i]}"; done
RET_IDX=${#PASTAS[@]}
echo " [$RET_IDX] 🔙 Voltar ao menu Octave"
echo ""

read -p "Digite o número da pasta que deseja limpar: " escolha
[[ "$escolha" == "$RET_IDX" ]] && { bash "$SCRIPT_DIR/menu_octave.sh"; exit 0; }
if ! [[ "$escolha" =~ ^[0-9]+$ ]] || (( escolha < 0 || escolha >= ${#PASTAS[@]} )); then
  echo "❌ Opção inválida."; read -p "ENTER..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1
fi

PASTA="${PASTAS[$escolha]}"
ABS_PATH="$SIM_DIR/$PASTA"
echo ""
echo "⚠️ Confirma limpar TODO o conteúdo de:"
echo "   $ABS_PATH"
read -p "Digite 'SIM' para confirmar: " conf
[[ "$conf" != "SIM" ]] && { echo "❌ Operação cancelada."; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_octave.sh"; exit 0; }

rm -r "$ABS_PATH"
echo ""
echo "✅ Limpeza concluída em: $ABS_PATH"
read -p "Pressione ENTER para retornar ao menu Octave..."
bash "$SCRIPT_DIR/menu_octave.sh"; exit 0
