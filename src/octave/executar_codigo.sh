#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Caminhos via env.sh (com fallbacks)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"

COD_DIR="$CODES_BASE/octave"
SIM_DIR="$SIMS_BASE/octave"

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
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_octave.sh"
fi

mapfile -t SCRIPTS < <(cd "$COD_DIR" && find . -maxdepth 1 -type f -name "*.m" -printf "%f\n" | sort)
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum script .m encontrado em $COD_DIR"
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_octave.sh"
fi

echo "📜 Scripts disponíveis em $(basename "$COD_DIR"):"
for s in "${SCRIPTS[@]}"; do echo "  - ${s%.m}"; done
echo ""
read -r -p "Digite o nome do script (sem .m): " nome
[[ -z "$nome" ]] && { echo "❌ Nome vazio."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_octave.sh"; }
ALVO="$COD_DIR/$nome.m"
[[ ! -f "$ALVO" ]] && { echo "❌ Script não encontrado: $ALVO"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_octave.sh"; }

# snapshot de dirs antes
cd "$COD_DIR" || { echo "❌ Falha ao acessar $COD_DIR"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_octave.sh"; }
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
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_octave.sh"
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
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_octave.sh"
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
read -r -p "Pressione ENTER para retornar ao menu Octave..." _
exec bash "$SCRIPT_DIR/menu_octave.sh"
