#!/bin/bash
# Limpeza de simulações OpenFOAM (AESC) – caminhos relativos

# Diretórios base relativos à localização deste script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # .../AESC/src/openfoam
ROOT_DIR="$(dirname "$SCRIPT_DIR")"                                # .../AESC/src
OPENFOAM_SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/openfoam")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║        Ambiente de execução – OpenFOAM 🌀 | Limpeza de simulações            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar diretório de simulações
if [[ ! -d "$OPENFOAM_SIM_DIR" ]]; then
  echo "❌ Diretório de simulações OpenFOAM não encontrado:"
  echo "   $OPENFOAM_SIM_DIR"
  read -p "Pressione Enter para retornar ao menu..."
  bash "$SCRIPT_DIR/menu_openfoam.sh"
  exit 1
fi

# 📂 Listar solvers disponíveis
echo "📂 Solvers com casos disponíveis para limpeza:"
( cd "$OPENFOAM_SIM_DIR" && ls -1 )
echo ""
read -p "✍️  Digite o nome do solver cujo caso deseja limpar: " SOLVER

# 📁 Listar casos disponíveis para o solver
SOLVER_DIR="$OPENFOAM_SIM_DIR/$SOLVER"
if [[ ! -d "$SOLVER_DIR" ]]; then
  echo "❌ Solver '$SOLVER' não encontrado em: $OPENFOAM_SIM_DIR"
  read -p "Pressione Enter para retornar ao menu..."
  bash "$SCRIPT_DIR/menu_openfoam.sh"
  exit 1
fi

echo ""
echo "📁 Casos disponíveis para limpeza no solver '$SOLVER':"
( cd "$SOLVER_DIR" && ls -1 )
echo ""
read -p "✍️  Digite o nome do caso que deseja limpar: " CASO

DIR="$SOLVER_DIR/$CASO"

if [[ ! -d "$DIR" ]]; then
  echo "❌ Caso '$CASO' não encontrado em: $SOLVER_DIR"
  read -p "Pressione Enter para retornar ao menu..."
  bash "$SCRIPT_DIR/menu_openfoam.sh"
  exit 1
fi

# Detectar script de limpeza local
CLEAN_SH=""
if   [[ -f "$DIR/Allclean.sh" ]]; then CLEAN_SH="Allclean.sh"
elif [[ -f "$DIR/Allclean"    ]]; then CLEAN_SH="Allclean"
fi

# 📦 Obter lista de pastas de tempo (ignora '0', 'constant' etc.)
TEMPOS=$(find "$DIR" -maxdepth 1 -type d -regex '.*/[0-9]+(\.[0-9]+)?$' -printf '%f\n' 2>/dev/null)
IFS=$'\n' read -rd '' -a PASTAS <<<"$TEMPOS"
TOTAL=${#PASTAS[@]}

if [ "$TOTAL" -eq 0 ]; then
  echo "⚠️  Nenhuma pasta de tempo encontrada para apagar. Executando rotina de limpeza mesmo assim..."
else
  echo ""
  echo "🧹 Limpando $TOTAL pastas temporais do caso '$CASO'..."
  COUNT=0
  for PASTA in "${PASTAS[@]}"; do
    rm -rf "$DIR/$PASTA"
    COUNT=$((COUNT+1))
    PERC=$((100 * COUNT / TOTAL))
    echo -ne "⏳ Progresso: $PERC% concluído...\r"
    sleep 0.1
  done
  echo -ne "\n"
fi

echo ""
echo "⚙️  Executando rotina de limpeza do caso (Allclean)..."
if [[ -n "$CLEAN_SH" ]]; then
  ( cd "$DIR" && bash "$CLEAN_SH" )
else
  echo "⚠️  Script de limpeza (Allclean/Allclean.sh) não encontrado em:"
  echo "   $DIR"
fi

echo ""
echo "✅ Limpeza do caso '$CASO' concluída com sucesso!"
read -p "Pressione Enter para retornar ao menu OpenFOAM..."
bash "$SCRIPT_DIR/menu_openfoam.sh"
