#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║             Ambiente de execução – OpenFOAM 🌀 | Limpar Compilação           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Carrega o ambiente openfoam2412
source /usr/lib/openfoam/openfoam2412/etc/bashrc

# Caminho relativo à raiz onde estão os códigos
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
SOLVER_DIR="$BASE_DIR/codigos/openfoam"


# Verifica se a pasta de solvers existe
if [ ! -d "$SOLVER_DIR" ]; then
  echo "❌ Pasta de solvers não encontrada em '$SOLVER_DIR'"
  echo "Certifique-se de que a estrutura de pastas está correta."
  sleep 3
  exit 1
fi

# Lista os solvers disponíveis
echo "📦 Solvers disponíveis para limpeza:"
echo "----------------------------------------"
for solver in "$SOLVER_DIR"/*/; do
    solver_name=$(basename "$solver")
    echo "🔸 $solver_name"
done
echo "----------------------------------------"
echo ""

# Solicita o nome do solver ao usuário
read -p "Digite o nome do solver cuja compilação deseja limpar: " solver
echo ""

# Caminho completo para o solver
SOLVER_PATH="$SOLVER_DIR/$solver"

# Verifica se o diretório informado existe
if [ ! -d "$SOLVER_PATH" ]; then
  echo "❌ Diretório não encontrado: $SOLVER_PATH"
  echo "Certifique-se de digitar um nome válido da lista acima."
  sleep 3
  exit 1
fi

# Vai para o diretório do solver
cd "$SOLVER_PATH"

# Limpa a compilação com wclean
echo "🔧 Limpando compilação com wclean..."
sleep 1

wclean

# Verifica resultado da compilação
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Limpeza de compilação bem sucedida!"
else
  echo ""
  echo "❌ Erro na limpeza de compilação."
fi

echo ""
read -p "Pressione ENTER para voltar ao menu do OpenFOAM..."

# Volta ao menu OpenFOAM
bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
