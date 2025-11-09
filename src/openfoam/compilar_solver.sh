#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║             Ambiente de execução – OpenFOAM 🌀 | Compilar Solver             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  if [ -f "$_aesc_env" ]; then
    # shellcheck disable=SC1090
    . "$_aesc_env"
    break
  fi
done
unset _aesc_env

# ─────────────────────────── OpenFOAM bashrc (fallback seguro) ─────────────────
if [ -n "${AESC_OPENFOAM_BASHRC:-}" ] && [ -f "$AESC_OPENFOAM_BASHRC" ]; then
  # shellcheck disable=SC1090
  source "$AESC_OPENFOAM_BASHRC"
else
  # Caminho antigo herdado (mantém compatibilidade)
  # shellcheck disable=SC1091
  source /usr/lib/openfoam/openfoam2412/etc/bashrc
fi

# ─────────────────────────── Diretório dos solvers ─────────────────────────────
# Preferir env.sh (codes/), mantendo compat com árvore antiga (codigos/)
if [ -n "${AESC_CODES_DIR:-}" ] && [ -d "$AESC_CODES_DIR/openfoam" ]; then
  SOLVER_DIR="$AESC_CODES_DIR/openfoam"
else
  # Fallback por árvore relativa ao script
  SCRIPT_PATH="$(readlink -f "$0")"
  BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
  if [ -d "$BASE_DIR/codes/openfoam" ]; then
    SOLVER_DIR="$BASE_DIR/codes/openfoam"
  else
    SOLVER_DIR="$BASE_DIR/codigos/openfoam"
  fi
fi

# Verifica se a pasta de solvers existe
if [ ! -d "$SOLVER_DIR" ]; then
  echo "❌ Pasta de solvers não encontrada em '$SOLVER_DIR'"
  echo "Certifique-se de que a estrutura de pastas está correta."
  sleep 3
  exit 1
fi

# Lista os solvers disponíveis
echo "📦 Solvers disponíveis para compilação:"
echo "----------------------------------------"
has_any=0
for solver in "$SOLVER_DIR"/*/; do
  [ -d "$solver" ] || continue
  solver_name="$(basename "$solver")"
  echo "🔸 $solver_name"
  has_any=1
done
echo "----------------------------------------"
echo ""

if [ "$has_any" -eq 0 ]; then
  echo "ℹ️  Nenhum solver encontrado em: $SOLVER_DIR"
  echo "    Adicione um diretório por solver (ex.: $SOLVER_DIR/meuSolver/) e tente novamente."
  sleep 3
  exit 1
fi

# Solicita o nome do solver ao usuário
read -r -p "Digite o nome do solver que deseja compilar: " solver
echo ""

# Caminho completo para o solver
SOLVER_PATH="$SOLVER_DIR/$solver"

# Verifica se o diretório informado existe
if [ ! -d "$SOLVER_PATH" ]; then
  echo "❌ Diretório não encontrado: $SOLVER_PATH"
  echo "Certifique-se de digitar um nome válido da lista acima."
  sleep 3
  exit 1
fi

# Vai para o diretório do solver
cd "$SOLVER_PATH" || exit 1

# Compila o solver com wmake
echo "🔧 Iniciando compilação com wmake..."
sleep 1

wmake > log.compilacao 2>&1
status=$?

# Verifica resultado da compilação
if [ $status -eq 0 ]; then
  echo ""
  echo "✅ Solver compilado com sucesso!"
  echo "📁 Log salvo em: $SOLVER_PATH/log.compilacao"
else
  echo ""
  echo "❌ Erro na compilação do solver (status: $status)."
  echo "📄 Consulte o log em: $SOLVER_PATH/log.compilacao"
fi

echo ""
read -r -p "Pressione ENTER para voltar ao menu do OpenFOAM..." _

# Volta ao menu OpenFOAM (usa AESC_ROOT quando disponível; fallback para BASE_DIR)
if [ -n "${AESC_ROOT:-}" ] && [ -f "$AESC_ROOT/src/openfoam/menu_openfoam.sh" ]; then
  bash "$AESC_ROOT/src/openfoam/menu_openfoam.sh"
else
  # Fallback relativo
  bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
fi
