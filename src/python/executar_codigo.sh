#!/bin/bash
# Executar códigos Python científicos (AESC)
# - Lista projetos/arquivos .py em codigos/python (suporta subpastas, ex.: MLRM-MHT/MLRM-MHT.py)
# - Ativa venv ~/venvs/python-sci se existir
# - Executa no diretório do projeto
# - Cria previamente simulacoes/python/mlrun_<timestamp> e exporta AESC_OUTDIR para o .py salvar lá
# - Se nada for salvo em AESC_OUTDIR, aplica fallback coletando outputs locais

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
COD_DIR="$(readlink -f "$ROOT_DIR/../codigos/python")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/python")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║         Ambiente – Python Científico 🐍 | Seleção e execução de scripts      ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Checagens
if [[ ! -d "$COD_DIR" ]]; then
  echo "❌ Diretório de códigos Python não encontrado: $COD_DIR"
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_python.sh"; exit 1
fi
mkdir -p "$SIM_DIR"

# Tentar ativar venv (opcional)
if [[ -f "$HOME/venvs/python-sci/bin/activate" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/venvs/python-sci/bin/activate"
else
  echo "ℹ️  Aviso: ambiente virtual ~/venvs/python-sci não encontrado. Prosseguindo com Python do sistema."
fi

# Coleta de candidatos (.py) até profundidade 2 (ex.: MLRM-MHT/MLRM-MHT.py)
mapfile -t PYFILES < <(cd "$COD_DIR" && find . -maxdepth 2 -type f -name "*.py" -printf "%P\n" | sort)
if [[ ${#PYFILES[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum arquivo .py encontrado em: $COD_DIR"
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_python.sh"; exit 0
fi

echo "📜 Scripts disponíveis (relativos a $(basename "$COD_DIR")):"
for i in "${!PYFILES[@]}"; do
  echo " [$i] ${PYFILES[$i]}"
done
RET_IDX=${#PYFILES[@]}
echo " [$RET_IDX] 🔙 Voltar ao menu Python Científico"
echo ""
read -p "Digite o número do script que deseja executar: " choice

if [[ "$choice" == "$RET_IDX" ]]; then
  bash "$SCRIPT_DIR/menu_python.sh"; exit 0
fi
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 0 || choice >= ${#PYFILES[@]} )); then
  echo "❌ Opção inválida."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_python.sh"; exit 1
fi

REL_PATH="${PYFILES[$choice]}"
SCRIPT_ABS="$COD_DIR/$REL_PATH"
SCRIPT_DIR_ABS="$(dirname "$SCRIPT_ABS")"
SCRIPT_BASENAME="$(basename "$SCRIPT_ABS")"

echo ""
echo "🚀 Executando: $REL_PATH"
echo "   Pasta de execução: $SCRIPT_DIR_ABS"
echo ""

# ===== Preparar pasta de saída da execução =====
RUN_STAMP=$(date +'%Y%m%d-%H%M%S')
RUN_DIR="$SIM_DIR/mlrun_${RUN_STAMP}"
mkdir -p "$RUN_DIR"

# Marcar início e snapshot (apenas para fallback)
cd "$SCRIPT_DIR_ABS" || { echo "❌ Falha ao acessar $SCRIPT_DIR_ABS"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_python.sh"; exit 1; }
mapfile -t DIRS_BEFORE < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)
START_EPOCH=$(date +%s)

# ===== Executar Python com AESC_OUTDIR definido =====
echo "📁 Pasta de saída definida: $RUN_DIR"
export AESC_OUTDIR="$RUN_DIR"

python "$SCRIPT_BASENAME"
STATUS=$?

echo ""
if [[ $STATUS -ne 0 ]]; then
  echo "❌ Execução retornou código de erro ($STATUS)."
  read -p "ENTER para voltar..." ; bash "$SCRIPT_DIR/menu_python.sh"; exit 1
fi

# Se o script gerou algo em $RUN_DIR, consideramos OK e não fazemos fallback
if [[ -d "$RUN_DIR" ]] && [[ -n "$(find "$RUN_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
  echo "✅ Saída detectada em: $RUN_DIR"
  echo ""
  read -p "Pressione ENTER para retornar ao menu Python Científico..."
  bash "$SCRIPT_DIR/menu_python.sh"; exit 0
fi

# ===== Fallback (se nada foi escrito em AESC_OUTDIR) =====
# Snapshot depois, procurar novas pastas e/ou arquivos modificados no diretório do script
mapfile -t DIRS_AFTER < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)

declare -A BEFORE_MAP; for d in "${DIRS_BEFORE[@]}"; do BEFORE_MAP["$d"]=1; done
NEW_DIRS=(); for d in "${DIRS_AFTER[@]}"; do [[ -z "${BEFORE_MAP[$d]}" ]] && NEW_DIRS+=("$d"); done

TARGET_DIR=""
if [[ ${#NEW_DIRS[@]} -gt 0 ]]; then
  CANDIDATES=()
  for d in "${NEW_DIRS[@]}"; do
    mt=$(stat -c "%Y" "$d" 2>/dev/null || echo 0)
    (( mt >= START_EPOCH )) && CANDIDATES+=("$d")
  done
  if [[ ${#CANDIDATES[@]} -gt 0 ]]; then
    newest=$(printf "%s\n" "${CANDIDATES[@]}" | while read -r dn; do stat -c "%Y %n" "$dn"; done | sort -n | tail -1 | cut -d' ' -f2-)
    TARGET_DIR="$newest"
  else
    newest=$(printf "%s\n" "${NEW_DIRS[@]}" | while read -r dn; do stat -c "%Y %n" "$dn"; done | sort -n | tail -1 | cut -d' ' -f2-)
    TARGET_DIR="$newest"
  fi
fi

if [[ -n "$TARGET_DIR" && -d "$TARGET_DIR" ]]; then
  echo "📦 Movendo pasta criada localmente para: $RUN_DIR"
  shopt -s dotglob
  mv "$TARGET_DIR"/* "$RUN_DIR"/ 2>/dev/null || true
  rmdir "$TARGET_DIR" 2>/dev/null || true
else
  echo "📦 Coletando arquivos modificados após o início para: $RUN_DIR"
  while IFS= read -r -d '' f; do
    rel="${f#./}"
    [[ "$rel" == "$SCRIPT_BASENAME" ]] && continue
    cp -f "$rel" "$RUN_DIR/" 2>/dev/null || true
  done < <(find . -maxdepth 1 -type f -printf "%T@ %P\0" | awk -v start="$START_EPOCH" -v RS='\0' '{ if ($1>=start) print $0 }' | cut -d' ' -f2- | tr '\n' '\0')
fi

echo ""
if [[ -z "$(find "$RUN_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
  echo "⚠️ Nenhuma saída detectada. Pasta criada, porém vazia: $RUN_DIR"
else
  echo "✅ Saída organizada em: $RUN_DIR"
fi

read -p "Pressione ENTER para retornar ao menu Python Científico..."
bash "$SCRIPT_DIR/menu_python.sh"; exit 0
