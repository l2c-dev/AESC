#!/bin/bash

# Diretório do script atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Diretório onde o código será armazenado
CODIGO_DIR="$SCRIPT_DIR/../../codigos/simmsus"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║    Ambiente de execução – SIMMSUS 🧲 | Compilação de código-fonte com IFX    ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""


# Verificação de dependências
if ! command -v git &> /dev/null; then
  echo "❌ Git não encontrado. Por favor, instale o Git antes de continuar."
  exit 1
fi

if ! command -v ifx &> /dev/null; then
  echo "❌ Compilador Intel (ifx) não encontrado no sistema."
  echo "   Certifique-se de que o Intel oneAPI esteja instalado e configurado corretamente."
  exit 1
fi

# Clonagem ou atualização do repositório
if [ ! -d "$CODIGO_DIR/.git" ]; then
  echo "📥 Clonando o repositório do SIMMSUS..."
  mkdir -p "$CODIGO_DIR"
  cd "$CODIGO_DIR" || exit 1
  git clone https://github.com/lcec-unb/simmsus.git .
else
  echo "🔄 Atualizando o repositório existente (git pull)..."
  cd "$CODIGO_DIR" || exit 1
  git pull origin main
fi


# Compilação com make (duas vezes)
cd "$CODIGO_DIR" || exit 1
echo ""
echo "🛠️ Iniciando compilação..."
make gfortran &>log.compilacao1
rm log.compilacao1

# Verificação do executável
if [ -f "$CODIGO_DIR/simmsus.ex" ]; then
  echo ""
  echo "✅ Compilação finalizada com sucesso!"
  echo "🔧 Executável gerado: simmsus.ex"
else
  echo ""
  echo "❌ A compilação não gerou o executável esperado (simmsus.ex)."
  echo "   Verifique mensagens de erro acima ou dependências ausentes no sistema."
fi
