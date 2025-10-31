#!/bin/bash

# Diretório em que esse script se encontra

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║  Este menu permite acessar diferentes ambientes de simulação computacional   ║"
echo "║                       Use os números para navegar.                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
}

while true; do
    clear
    print_header
    echo ""
    echo "🌐 Ambientes disponíveis:"
    echo ""
    echo " [1] - OpenFOAM 🌀 "
    echo " [2] - SIMMSUS 🧲 "
    echo " [3] - PINNs 🤖 "
    echo " [4] - Octave scripts 📉 "
    echo " [5] - Python científico 🐍 "
    echo " [6] - LIGGGHTS ⚙️  "
    echo " [7] - GIT 🧰 "
    echo " [8] - Acessar terminal (sair) 🖥️  "
    echo ""
    read -p "Digite o número da opção desejada: " opcao
    echo ""

    case $opcao in
        1)
            bash "$SCRIPT_DIR/openfoam/menu_openfoam.sh"
            ;;
        2)
            bash "$SCRIPT_DIR/simmsus/menu_simmsus.sh"
            ;;
        3)
            bash "$SCRIPT_DIR/pinn/menu_pinn.sh"
            ;;
        4)
            bash "$SCRIPT_DIR/octave/menu_octave.sh"
            ;;
        5)
 # subshell: ativa venv e entra no menu python
           (
             if [ -f "$HOME/venvs/python-sci/bin/activate" ]; then
            source "$HOME/venvs/python-sci/bin/activate"
             else
            echo "⚠️  venv não encontrado em ~/venvs/python-sci. Prosseguindo com Python do sistema."
             fi
              bash "$SCRIPT_DIR/python/menu_python.sh"
            )
            ;;

        6)
            echo "🔧 Ambiente LIGGGHTS ainda não implementado..."
            sleep 1
            echo "🔙 Voltando ao menu principal..."
            sleep 0.6
            ;;
        7)
            bash "$SCRIPT_DIR/git/menu_git.sh"
            ;;
        8)
            echo "🖥️  Acessando terminal..."
            sleep 1
            exit 0
            ;;
        *)
            echo "❌ Opção inválida. Tente novamente."
            ;;
    esac
done
