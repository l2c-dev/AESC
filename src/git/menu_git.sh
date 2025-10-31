#!/bin/bash
# Menu Git – AESC (100% offline)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                   Ambiente de execução – Git 🧰 | Projetos                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] ⬇️  Clonar repositório do GitHub"
  echo " [2] 🆕 Iniciar repositório científico (template mínimo)"
  echo " [3] 📝 Gerar/atualizar README.md (wizard offline)"
  echo " [4] 📜 Menu ajuda"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -p "Digite a opção desejada: " opc

  case "$opc" in
    1) bash "$SCRIPT_DIR/clonar_repo.sh" ;;
    2) bash "$SCRIPT_DIR/iniciar_projeto.sh" ;;
    3) bash "$SCRIPT_DIR/gerar_readme.sh" ;;
    4) bash "$SCRIPT_DIR/menu_ajuda.sh" ;;
    0) 
       echo "🔙 Voltando ao menu principal..."
       sleep 0.4
       break
       ;;
    *) echo "❌ Opção inválida. Tente novamente." ;;
  esac

  echo ""
  read -p "Pressione ENTER para retornar ao menu Git..."
  clear
done
exit 0
