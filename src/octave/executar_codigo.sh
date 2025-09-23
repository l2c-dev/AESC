#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
COD_DIR="$(readlink -f "$ROOT_DIR/../codigos/octave")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/octave")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║               Ambiente de execução – Octave 📉 | Executar script             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$COD_DIR" || ! -d "$SIM_DIR" ]]; then
  echo "❌ Estrutura não encontrada."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1
fi

mapfile -t SCRIPTS < <(cd "$COD_DIR" && find . -maxdepth 1 -type f -name "*.m" -printf "%f\n" | sort)
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum script .m encontrado em $COD_DIR"
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 0
fi

echo "📜 Scripts disponíveis em $(basename "$COD_DIR"):"
for s in "${SCRIPTS[@]}"; do echo "  - ${s%.m}"; done
echo ""
read -p "Digite o nome do script (sem .m): " nome
[[ -z "$nome" ]] && { echo "❌ Nome vazio."; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1; }
ALVO="$COD_DIR/$nome.m"
[[ ! -f "$ALVO" ]] && { echo "❌ Script não encontrado: $ALVO"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1; }

# snapshot de dirs antes
cd "$COD_DIR" || { echo "❌ Falha ao acessar $COD_DIR"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1; }
mapfile -t DIRS_BEFORE < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)

echo ""
echo "🚀 Executando: octave -qf $(basename "$ALVO")"
echo "   (aguarde a finalização; logs/prints são do script Octave)"
echo ""

octave -qf "$ALVO"
OCT_STATUS=$?

echo ""
if [[ $OCT_STATUS -ne 0 ]]; then
  echo "❌ Execução retornou código de erro ($OCT_STATUS)."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 1
fi

# snapshot de dirs depois
mapfile -t DIRS_AFTER < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)

declare -A SEEN; for d in "${DIRS_BEFORE[@]}"; do SEEN["$d"]=1; done
NEW_DIRS=(); for d in "${DIRS_AFTER[@]}"; do [[ -z "${SEEN[$d]}" ]] && NEW_DIRS+=("$d"); done

TARGET_DIR=""
if [[ ${#NEW_DIRS[@]} -gt 0 ]]; then
  newest=$(printf "%s\n" "${NEW_DIRS[@]}" | while read -r dn; do stat -c "%Y %n" "$dn"; done | sort -n | tail -1 | cut -d' ' -f2-)
  TARGET_DIR="$newest"
else
  newest=$(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2-)
  TARGET_DIR="$newest"
fi

if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
  echo "⚠️ Não foi possível identificar a pasta de saída criada pelo script."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_octave.sh"; exit 0
fi

SRC_ABS="$COD_DIR/$TARGET_DIR"
DEST_ABS="$SIM_DIR/$(basename "$TARGET_DIR")"
[[ -e "$DEST_ABS" ]] && DEST_ABS="${DEST_ABS}_$(date +'%Y%m%d-%H%M%S')"

echo "📦 Movendo saída:"
echo "   De: $SRC_ABS"
echo "   Para: $DEST_ABS"
mv "$SRC_ABS" "$DEST_ABS"

echo ""
echo "✅ Execução concluída e saída organizada."
echo "📁 Pasta da simulação: $DEST_ABS"
echo ""
read -p "Pressione ENTER para retornar ao menu Octave..."
bash "$SCRIPT_DIR/menu_octave.sh"; exit 0
