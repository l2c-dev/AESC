#!/bin/bash

clear
# Identificando a pasta raiz do sistema AESC (.scripts)
SCRIPT_PATH="$(readlink -f "$0")"
BASE_DIR="$(dirname "$(dirname "$SCRIPT_PATH")")"


echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                     Ambiente de execução – OpenFOAM 🌀                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "Escolha uma das opções abaixo:"
echo ""
echo "1 - Compilar um solver personalizado"
echo "2 - Limpar a compilação de um solver"
echo "3 - Executar uma simulação"
echo "4 - Monitorar simulação em andamento"
echo "5 - Limpar arquivos temporários do caso"
echo "6 - Voltar ao menu principal"
echo ""

read -p "Digite a opção desejada: " opcao

case $opcao in
  1)
    sleep 2
    bash "$BASE_DIR/openfoam/compilar_solver.sh"
    ;;
  2)
    sleep 2
    bash "$BASE_DIR/openfoam/limpar_compilacao.sh"
    ;;
  3)
    sleep 2
    bash "$BASE_DIR/openfoam/executar_simulacao.sh"
    ;;
  4)
    sleep 2
    bash "$BASE_DIR/openfoam/monitorar_processos.sh"
    ;;
  5)
    sleep 2
    bash "$BASE_DIR/openfoam/limpar_caso.sh"
    ;;
  6)
    echo "🔙 Voltando ao menu principal..."
    sleep 0.4
    break
    ;;
  *)
    echo "Opção inválida. Retornando ao menu principal..."
    sleep 2
    bash "$BASE_DIR/aesc.sh"
    ;;
esac
