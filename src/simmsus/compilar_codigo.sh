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
echo "║     Ambiente de execução – SIMMSUS 🧲 | Compilação (IFX ou GFORTRAN)         ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ───────────────────────────────── Verificações básicas
if ! command -v git >/dev/null 2>&1; then
  echo "❌ Git não encontrado. Instale o Git e tente novamente."
  exit 1
fi
if ! command -v make >/dev/null 2>&1; then
  echo "❌ 'make' não encontrado. Instale o 'build-essential' (ou equivalente) e tente novamente."
  exit 1
fi

# ───────────────────────────────── Fontes: pull/clone/usar snapshot
if [ -d "$CODIGO_DIR/.git" ]; then
  echo "🔄 Repositório Git detectado em codigos/simmsus (submódulo). Executando git pull..."
  git -C "$CODIGO_DIR" pull origin main
else
  if [ -d "$CODIGO_DIR" ] && [ "$(ls -A "$CODIGO_DIR" 2>/dev/null)" ]; then
    echo "📦 Fontes do SIMMSUS já presentes (snapshot). Pulando etapa de Git."
  else
    echo "📥 Clonando o repositório do SIMMSUS para codigos/simmsus..."
    mkdir -p "$CODIGO_DIR"
    git clone https://github.com/lcec-unb/simmsus.git "$CODIGO_DIR"
  fi
fi

cd "$CODIGO_DIR" || exit 1

# ───────────────────────────────── Escolha do compilador
USE_IFX=false
if command -v ifx >/dev/null 2>&1; then
  USE_IFX=true
else
  echo "⚠️  IFX (Intel oneAPI) não encontrado no sistema."
  read -r -p "❔ Deseja compilar com GFORTRAN? [s/N]: " RESP
  RESP="${RESP,,}"
  if [[ "$RESP" == "s" || "$RESP" == "sim" || "$RESP" == "y" || "$RESP" == "yes" ]]; then
    if ! command -v gfortran >/dev/null 2>&1; then
      echo "❌ GFORTRAN não encontrado. Instale-o e tente novamente."
      exit 1
    fi
    USE_IFX=false
  else
    echo "🚫 Operação cancelada (sem compilador disponível)."
    exit 1
  fi
fi

# ───────────────────────────────── Compilação
echo ""
if $USE_IFX; then
  echo "🛠️ Compilando com IFX..."
  make ifx  &> log.compilacao.ifx
  COMP_LOG="log.compilacao.ifx"
else
  echo "🛠️ Compilando com GFORTRAN..."
  make gfortran  &> log.compilacao.gfortran
  COMP_LOG="log.compilacao.gfortran"
fi

# ───────────────────────────────── Verificação do executável
if [ -f "$CODIGO_DIR/simmsus.ex" ]; then
  echo ""
  echo "✅ Compilação finalizada com sucesso!"
  echo "🔧 Executável gerado: simmsus.ex"
  rm -f log.compilacao.ifx log.compilacao.gfortran 2>/dev/null
else
  echo ""
  echo "❌ A compilação não gerou o executável esperado (simmsus.ex)."
  echo "ℹ️  Consulte o log recente: $COMP_LOG"
fi
