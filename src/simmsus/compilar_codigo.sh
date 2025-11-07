#!/bin/bash

# Diretórios base (independente de onde for chamado)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AESC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"                 # .../aesc
CODIGO_DIR="$AESC_ROOT/codigos/simmsus"                     # .../aesc/codigos/simmsus

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

# ───────────────────────────────── Obter/atualizar fontes
if [ -d "$CODIGO_DIR/.git" ]; then
  echo "🔄 Repositório Git detectado em codigos/simmsus. Executando git pull..."
  git -C "$CODIGO_DIR" pull --rebase --autostash origin main || { echo "❌ git pull falhou."; exit 1; }
else
  # Snapshot (sem .git). Tentar 'git subtree pull' no repositório raiz do AESC
  if git -C "$AESC_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "🌿 Snapshot detectado. Atualizando via git subtree no repositório AESC..."
    # Usa URL remota; --squash mantém histórico compacto.
    git -C "$AESC_ROOT" subtree pull --prefix=codigos/simmsus https://github.com/lcec-unb/simmsus.git main --squash \
      || {
        echo "⚠️  'git subtree pull' falhou."
        read -r -p "❔ Deseja substituir por um clone direto do SIMMSUS? [s/N]: " RESP
        RESP="${RESP,,}"
        if [[ "$RESP" == "s" || "$RESP" == "sim" || "$RESP" == "y" || "$RESP" == "yes" ]]; then
          TS="$(date +%Y%m%d-%H%M%S)"
          BACKUP_DIR="${CODIGO_DIR}_snapshot_backup_${TS}"
          echo "🗂️  Fazendo backup do snapshot em: $BACKUP_DIR"
          mv "$CODIGO_DIR" "$BACKUP_DIR" || { echo "❌ Falha ao mover snapshot."; exit 1; }
          echo "📥 Clonando repositório oficial..."
          git clone https://github.com/lcec-unb/simmsus.git "$CODIGO_DIR" || { echo "❌ Falha no clone."; exit 1; }
        else
          echo "🚫 Operação cancelada (sem atualização)."
          exit 1
        fi
      }
  else
    echo "📦 Fontes presentes sem .git e AESC não é um repositório Git."
    read -r -p "❔ Deseja substituir por um clone direto do SIMMSUS? [s/N]: " RESP
    RESP="${RESP,,}"
    if [[ "$RESP" == "s" || "$RESP" == "sim" || "$RESP" == "y" || "$RESP" == "yes" ]]; then
      TS="$(date +%Y%m%d-%H%M%S)"
      BACKUP_DIR="${CODIGO_DIR}_snapshot_backup_${TS}"
      echo "🗂️  Fazendo backup do snapshot em: $BACKUP_DIR"
      mv "$CODIGO_DIR" "$BACKUP_DIR" || { echo "❌ Falha ao mover snapshot."; exit 1; }
      echo "📥 Clonando repositório oficial..."
      git clone https://github.com/lcec-unb/simmsus.git "$CODIGO_DIR" || { echo "❌ Falha no clone."; exit 1; }
    else
      echo "🚫 Operação cancelada (sem atualização)."
      exit 1
    fi
  fi
fi

# ───────────────────────────────── Determinar diretório de build (novo x antigo)
has_makefile() {
  # retorna 0 (true) se existir Makefile/makefile/GNUmakefile no diretório passado
  local d="$1"
  [ -f "$d/Makefile" ] || [ -f "$d/makefile" ] || [ -f "$d/GNUmakefile" ]
}

# ───────────────────────────────── Determinar diretório de build (novo x antigo)
BUILD_DIR=""
if [ -d "$CODIGO_DIR/src" ] && has_makefile "$CODIGO_DIR/src"; then
  BUILD_DIR="$CODIGO_DIR/src"
elif has_makefile "$CODIGO_DIR"; then
  BUILD_DIR="$CODIGO_DIR"
else
  echo "❌ Nenhum Makefile encontrado em:"
  echo "   - $CODIGO_DIR/src/{Makefile|makefile|GNUmakefile}"
  echo "   - $CODIGO_DIR/{Makefile|makefile|GNUmakefile}"
  echo "   Verifique a estrutura do repositório."
  exit 1
fi
# ───────────────────────────────── Escolha do compilador
USE_IFX=false
if command -v ifx >/dev/null 2>&1; then
  USE_IFX=true
else
  echo "⚠️  IFX (Intel oneAPI) não encontrado."
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
cd "$BUILD_DIR" || exit 1
if $USE_IFX; then
  echo "🛠️ Compilando com IFX..."
  make ifx  &>>  ../log.compilacao.ifx
   COMP_LOG="../log.compilacao.ifx"
else
  echo "🛠️ Compilando com GFORTRAN..."
  make gfortran  &>> ../log.compilacao.gfortran
  COMP_LOG="../log.compilacao.gfortran"
fi

# ───────────────────────────────── Pós-compilação, limpeza e compatibilidade
EXE_PATH=""

# 1. Identificar o executável gerado
if [ -f "$BUILD_DIR/simmsus.ex" ]; then
  EXE_PATH="$BUILD_DIR/simmsus.ex"
elif [ -f "$CODIGO_DIR/simmsus.ex" ]; then
  EXE_PATH="$CODIGO_DIR/simmsus.ex"
fi

# 2. Copiar executável para a pasta principal
if [ -n "$EXE_PATH" ]; then
  cp -f "$EXE_PATH" "$CODIGO_DIR/simmsus.ex"
  echo "📦 Executável copiado para: $CODIGO_DIR/simmsus.ex"
else
  echo "⚠️  Nenhum executável 'simmsus.ex' encontrado após compilação."
fi

# 3. Executar limpeza automática da pasta de build
if [ -f "$BUILD_DIR/Makefile" ] || [ -f "$BUILD_DIR/makefile" ]; then
  echo "🧹 Limpando arquivos temporários (make clean)..."
  (cd "$BUILD_DIR" && make clean > /dev/null 2>&1)
fi

# 4. Remover backups antigos de snapshot, se existirem
BACKUPS=$(find "$AESC_ROOT/codigos" -maxdepth 1 -type d -name "simmsus_snapshot_backup_*" 2>/dev/null)
if [ -n "$BACKUPS" ]; then
  echo "🧽 Removendo backups temporários antigos..."
  for BK in $BACKUPS; do
    rm -rf "$BK"
  done
fi

# 5. Mensagem final
if [ -f "$CODIGO_DIR/simmsus.ex" ]; then
  echo ""
  echo "✅ Compilação finalizada com sucesso!"
  echo "🔧 Executável disponível em: $CODIGO_DIR/simmsus.ex"
  rm -f "$CODIGO_DIR"/log.compilacao.* 2>/dev/null
else
  echo ""
  echo "❌ A compilação não gerou o executável esperado (simmsus.ex)."
  echo "ℹ️  Consulte o log: $COMP_LOG"
fi

