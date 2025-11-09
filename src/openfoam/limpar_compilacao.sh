#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║        Ambiente de execução – OpenFOAM 🌀 | Limpar Compilação de Solver      ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env

# ─────────────────────────── OpenFOAM bashrc (fallback seguro) ─────────────────
if [ -n "${AESC_OPENFOAM_BASHRC:-}" ] && [ -f "$AESC_OPENFOAM_BASHRC" ]; then
  # shellcheck disable=SC1090
  source "$AESC_OPENFOAM_BASHRC"
else
  # shellcheck disable=SC1091
  source /usr/lib/openfoam/openfoam2412/etc/bashrc
fi

# ─────────────────────────── Diretório dos solvers ─────────────────────────────
if [ -n "${AESC_CODES_DIR:-}" ] && [ -d "$AESC_CODES_DIR/openfoam" ]; then
  SOLVER_DIR="$AESC_CODES_DIR/openfoam"
else
  SCRIPT_PATH="$(readlink -f "$0")"
  BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
  if [ -d "$BASE_DIR/codes/openfoam" ]; then
    SOLVER_DIR="$BASE_DIR/codes/openfoam"
  else
    SOLVER_DIR="$BASE_DIR/codigos/openfoam"
  fi
fi

if [ ! -d "$SOLVER_DIR" ]; then
  echo "❌ Pasta de solvers não encontrada em '$SOLVER_DIR'"; sleep 2; exit 1
fi

echo "📦 Solvers disponíveis:"
echo "----------------------------------------"
solvers=()
while IFS= read -r -d '' d; do
  s="$(basename "$d")"; solvers+=("$s")
done < <(find "$SOLVER_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
if [ "${#solvers[@]}" -eq 0 ]; then
  echo "ℹ️  Nenhum solver encontrado em: $SOLVER_DIR"; sleep 2; exit 0
fi
for i in "${!solvers[@]}"; do printf " [%d] %s\n" "$((i+1))" "${solvers[$i]}"; done
echo "----------------------------------------"
read -r -p "Digite o número do solver a limpar a compilação: " idx; idx=$((idx-1))
if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#solvers[@]}" ]; then
  echo "❌ Opção inválida."; sleep 2; exit 1
fi
solver="${solvers[$idx]}"
SOLVER_PATH="$SOLVER_DIR/$solver"

cd "$SOLVER_PATH" || { echo "❌ Falha ao entrar em $SOLVER_PATH"; sleep 2; exit 1; }

echo ""
echo "🧹 Limpando artefatos de compilação (wclean)..."
sleep 1
if command -v wclean >/dev/null 2>&1; then
  wclean > log.limpeza_compilacao 2>&1 || true
else
  # Fallback simples caso wclean não exista
  rm -rf Make/linux* *.dep 2>/dev/null || true
  echo "(wclean não encontrado — limpeza básica aplicada)" >> log.limpeza_compilacao
fi
echo "✅ Limpeza de compilação concluída para '$solver'."
echo "📄 Log: $SOLVER_PATH/log.limpeza_compilacao"

echo ""
read -r -p "Pressione ENTER para voltar ao menu do OpenFOAM..." _
if [ -n "${AESC_ROOT:-}" ] && [ -f "$AESC_ROOT/src/openfoam/menu_openfoam.sh" ]; then
  bash "$AESC_ROOT/src/openfoam/menu_openfoam.sh"
else
  bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
fi
