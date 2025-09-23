#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║           Ambiente de execução – OpenFOAM 🌀 | Executar Simulação            ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Carrega o ambiente do OpenFOAM
source /usr/lib/openfoam/openfoam2412/etc/bashrc

# Define caminho base do sistema
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
SIMULATION_DIR="$BASE_DIR/simulacoes/openfoam"

# Verifica se a pasta de simulações existe
if [ ! -d "$SIMULATION_DIR" ]; then
  echo "❌ Pasta de simulações não encontrada em '$SIMULATION_DIR'"
  sleep 3
  exit 1
fi

# Lista os solvers disponíveis com casos
echo "📦 Solvers com casos disponíveis:"
echo "----------------------------------------"
for solver_path in "$SIMULATION_DIR"/*/; do
  solver_name=$(basename "$solver_path")
  echo "🔸 $solver_name"
done
echo "----------------------------------------"
echo ""

# Solicita o nome do solver ao usuário
read -p "Digite o nome do solver desejado: " solver
echo ""

SOLVER_PATH="$SIMULATION_DIR/$solver"

# Verifica se o diretório do solver existe
if [ ! -d "$SOLVER_PATH" ]; then
  echo "❌ Solver não encontrado em '$SOLVER_PATH'"
  sleep 3
  exit 1
fi

# Lista os casos disponíveis para esse solver
echo "📁 Casos disponíveis para o solver '$solver':"
echo "----------------------------------------"
for case_path in "$SOLVER_PATH"/*/; do
  case_name=$(basename "$case_path")
  echo "🔹 $case_name"
done
echo "----------------------------------------"
echo ""

# Solicita o nome do caso ao usuário
read -p "Digite o nome do caso desejado: " case
echo ""

CASE_PATH="$SOLVER_PATH/$case"

# Verifica se o diretório do caso existe
if [ ! -d "$CASE_PATH" ]; then
  echo "❌ Caso não encontrado em '$CASE_PATH'"
  sleep 3
  exit 1
fi

# Verifica se os scripts Allpre e Allrun existem e têm permissão de execução
if [ ! -x "$CASE_PATH/Allpre" ] || [ ! -x "$CASE_PATH/Allrun" ]; then
  echo "❌ Scripts 'Allpre' e/ou 'Allrun' não encontrados ou sem permissão de execução."
  echo "Verifique os arquivos dentro da pasta '$CASE_PATH'"
  sleep 3
  exit 1
fi

# Vai para o diretório do caso
cd "$CASE_PATH"

# Executa o pré-processamento (Allpre) normalmente
touch log.run
chmod 664 log.run
echo "⚙️  Executando pré-processamento (Allpre)..."
echo "🔄 Início: $(date)" > log.run
echo "[Allpre]" >> log.run 2>&1
./Allpre >> log.run 2>&1

# Executa o Allrun em segundo plano com nohup
echo "" >> log.run
echo "🚀 Iniciando simulação (Allrun) em segundo plano..."
echo "[Allrun]" >> log.run

nohup ./Allrun >> log.run 2>&1 &
sleep 1
PID=$(pgrep -u "$USER" -f "$solver")

echo "" >> log.run
echo "🧠 PID da simulação: $PID" >> log.run
echo "🏁 Simulação iniciada em: $(date)" >> log.run

# Feedback final
echo ""
echo "✅ Simulação iniciada para o caso '$case' com o solver '$solver'."
echo "📄 Log em: $CASE_PATH/log.run"
echo "🔢 PID do processo: $PID"
echo "ℹ️  Você pode monitorar ou finalizar a simulação pelo menu apropriado."
echo ""

read -p "Pressione ENTER para voltar ao menu do OpenFOAM..."

# Volta ao menu do OpenFOAM
bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
