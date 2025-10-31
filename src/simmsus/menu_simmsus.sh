#!/bin/bash

# Diretório em que esse script se encontra
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Diretório raiz dos scripts do sistema AESC
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

imprimir_cabecalho() {
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
  echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
  echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║                      Ambiente de execução – SIMMSUS 🧲                       ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
}

imprimir_cabecalho

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] 🛠️  Compilar a versão mais recente do código SIMMSUS"
  echo " [2] 📘 Assistente de criação de arquivo de configuração"
  echo " [3] 🧪 Executar simulação com base em simconfig.dat existente"
  echo " [4] 🧹 Limpar simulação (preserva simconfig.dat)"
  echo " [5] 📡 Monitorar simulação em andamento"
  echo " [6] 📘 Ajuda: estrutura de pastas e nomenclatura"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -p "Digite a opção desejada: " opcao

  case $opcao in
    1) bash "$SCRIPT_DIR/compilar_codigo.sh" ;;
    2) bash "$SCRIPT_DIR/gerar_simconfig.sh" ;;
    3) bash "$SCRIPT_DIR/executar_simulacao.sh" ;;
    4) bash "$SCRIPT_DIR/limpar_simulacao.sh" ;;
    5) bash "$SCRIPT_DIR/monitorar_simulacao.sh" ;;
    6) bash "$SCRIPT_DIR/menu_ajuda.sh" ;;
    0)
    echo "🔙 Voltando ao menu principal..."
    sleep 0.4
    break
    ;;
  esac

  echo ""
  read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
  imprimir_cabecalho
done
