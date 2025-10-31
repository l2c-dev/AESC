#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                Ambiente de execução – Octave 📉 | Scripts Numéricos          ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] ▶️  Executar script Octave"
  echo " [2] 🧹 Limpar simulação"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -p "Digite a opção desejada: " opcao

  case "$opcao" in
    1) bash "$SCRIPT_DIR/executar_codigo.sh" ;;
    2) bash "$SCRIPT_DIR/limpar_simulacao.sh" ;;
    0)
    echo "🔙 Voltando ao menu principal..."
    sleep 0.4
    break
    ;;
   *) echo "❌ Opção inválida. Tente novamente." ;;
  esac

  echo ""
  read -p "Pressione ENTER para retornar ao menu Octave..."
  clear
done
