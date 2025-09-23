#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SIMULACOES_DIR="$ROOT_DIR/../simulacoes/simmsus"
EXECUTAVEL_ORIGEM="$ROOT_DIR/../codigos/simmsus/simmsus.ex"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║         Ambiente de execução – SIMMSUS 🧲 | Execução de simulações           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verifica se há simulações disponíveis
if [ ! -d "$SIMULACOES_DIR" ]; then
  echo "❌ Diretório de simulações não encontrado: $SIMULACOES_DIR"
  exit 1
fi

cd "$SIMULACOES_DIR" || exit 1
PASTAS=(*)

if [ ${#PASTAS[@]} -eq 0 ]; then
  echo "⚠️ Nenhuma pasta de simulação encontrada em $SIMULACOES_DIR"
  exit 0
fi

echo "📁 Casos disponíveis para execução:"
echo ""

for i in "${!PASTAS[@]}"; do
  echo " [$i] ${PASTAS[$i]}"
done

echo ""
read -p "Digite o número da pasta que deseja executar: " escolha

CASO="${PASTAS[$escolha]}"
PASTA_CASO="$SIMULACOES_DIR/$CASO"

# Verificação do arquivo de configuração
if [ ! -f "$PASTA_CASO/simconfig.dat" ]; then
  echo "❌ Arquivo simconfig.dat não encontrado em $PASTA_CASO"
  exit 1
fi

# Verificação do executável
if [ ! -f "$EXECUTAVEL_ORIGEM" ]; then
  echo "❌ Executável simmsus.ex não encontrado em $EXECUTAVEL_ORIGEM"
  echo "   Certifique-se de compilar o código antes de executar simulações."
  exit 1
fi

# Cópia do executável e execução
echo ""
echo "🚀 Executando simulação no caso: $CASO"
cp "$EXECUTAVEL_ORIGEM" "$PASTA_CASO/"
cd "$PASTA_CASO" || exit 1

nohup ./simmsus.ex &> log.simmsus 2>&1 &
PID=$!

echo ""
echo "✅ Simulação iniciada em segundo plano (PID $PID)"
echo "📄 Log em tempo real salvo em: $PASTA_CASO/log.simmsus"
echo ""
read -p "Pressione ENTER para retornar ao menu SIMMSUS..."

bash "$SCRIPT_DIR/menu_simmsus.sh"
exit 0
