#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SIMULACOES_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/simmsus")"

while true; do
clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║       Ambiente de execução – SIMMSUS 🧲 | Monitoramento de simulações        ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Captura os PIDs dos processos simmsus.ex em execução
MAPA=()
INDEX=0

RAW_PROCESS_LIST=$(ps aux | grep '[s]immsus.ex')

if [[ -n "$RAW_PROCESS_LIST" ]]; then
  echo "📡 Processos em execução encontrados:"
  echo ""
fi

while read -r linha; do
  pid=$(echo "$linha" | awk '{print $2}')
  exe=$(readlink -f /proc/$pid/exe 2>/dev/null)

# Filtra apenas se for o binário simmsus.ex de verdade
  if [[ "$exe" != *simmsus.ex ]]; then
    continue
  fi

  cwd=$(readlink -f /proc/$pid/cwd 2>/dev/null)
  if [[ "$cwd" == "$SIMULACOES_DIR"* ]]; then
    echo " [$INDEX] 💻 PID $pid | 📁 $cwd"
    MAPA[$INDEX]="$pid|$cwd"
    ((INDEX++))
  fi
done < <(ps aux | grep '[s]immsus.ex')


if [ ${#MAPA[@]} -eq 0 ]; then
  echo ""
  echo "⚠️ Nenhuma simulação simmsus.ex em execução foi encontrada."
  echo ""
  read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"
fi

# Exibe opção de voltar ao menu principal
echo " [$INDEX] 🔙 Voltar ao menu SIMMSUS"

# Lê escolha do usuário
echo ""
read -p "Digite o número do processo que deseja gerenciar: " escolha

if [[ "$escolha" == "$INDEX" ]]; then
  echo "🔙 Retornando ao menu SIMMSUS..."
  sleep 1
  bash "$SCRIPT_DIR/menu_simmsus.sh"
  exit 0
fi

SELECIONADO="${MAPA[$escolha]}"
PID=$(echo "$SELECIONADO" | cut -d'|' -f1)
PASTA=$(echo "$SELECIONADO" | cut -d'|' -f2)

while true; do
  echo ""
  echo "🧠 Processo selecionado:"
  echo " PID: $PID"
  echo " Pasta: $PASTA"
  echo ""
  echo " [1] 📄 Ver últimas 20 linhas do log.simmsus"
  echo " [2] 🛑 Encerrar simulação (kill $PID)"
  echo " [0] 🔙 Voltar à lista de processos"
  echo ""

  read -p "Escolha uma ação: " acao

  case $acao in
    1)
      echo ""
      echo "📄 Últimas 20 linhas de $PASTA/log.simmsus:"
      echo "────────────────────────────────────────────"
      tail -n 20 "$PASTA/log.simmsus"
      echo "────────────────────────────────────────────"
      echo ""
      read -p "Pressione ENTER para retornar ao monitoramento do processo..."
      ;;
    2)
      kill "$PID"
      echo "🛑 Processo $PID encerrado."
      read -p "Pressione ENTER para retornar à lista de processos..."
      break
      ;;
    0)
      echo "🔙 Retornando à lista de processos..."
      sleep 1
      break
      ;;
    *)
      echo "❌ Opção inválida."
      ;;
  esac
done
done
