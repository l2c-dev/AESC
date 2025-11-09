#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║              Ambiente de execução – OpenFOAM 🌀 | Limpar Caso                ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env

# ─────────────────────────── Diretório de simulações ───────────────────────────
if [ -n "${AESC_SIMS_DIR:-}" ] && [ -d "$AESC_SIMS_DIR/openfoam" ]; then
  SIMS_DIR="$AESC_SIMS_DIR/openfoam"
else
  SCRIPT_PATH="$(readlink -f "$0")"
  BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
  if [ -d "$BASE_DIR/simulations/openfoam" ]; then
    SIMS_DIR="$BASE_DIR/simulations/openfoam"
  else
    SIMS_DIR="$BASE_DIR/simulacoes/openfoam"
  fi
fi

if [ ! -d "$SIMS_DIR" ]; then
  echo "❌ Pasta de simulações do OpenFOAM não encontrada em: $SIMS_DIR"
  sleep 2; exit 1
fi

# ─────────────────────────── Seleção do solver ─────────────────────────────────
echo "📦 Solvers com casos existentes:"
echo "---------------------------------"
solvers=()
while IFS= read -r -d '' d; do
  s="$(basename "$d")"; solvers+=("$s")
done < <(find "$SIMS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "${#solvers[@]}" -eq 0 ]; then
  echo "ℹ️  Nenhum solver encontrado em: $SIMS_DIR"
  sleep 2; exit 0
fi

for i in "${!solvers[@]}"; do printf " [%d] %s\n" "$((i+1))" "${solvers[$i]}"; done
echo "---------------------------------"
read -r -p "Escolha o solver (número): " idx; idx=$((idx-1))
if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#solvers[@]}" ]; then
  echo "❌ Opção inválida."; sleep 2; exit 1
fi
solver="${solvers[$idx]}"

# ─────────────────────────── Seleção do caso ───────────────────────────────────
CASE_ROOT="$SIMS_DIR/$solver"
echo ""
echo "📁 Casos do solver '$solver':"
echo "---------------------------------"
cases=()
while IFS= read -r -d '' d; do
  c="$(basename "$d")"; cases+=("$c")
done < <(find "$CASE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "${#cases[@]}" -eq 0 ]; then
  echo "ℹ️  Nenhum caso encontrado em: $CASE_ROOT"
  sleep 2; exit 0
fi

for i in "${!cases[@]}"; do printf " [%d] %s\n" "$((i+1))" "${cases[$i]}"; done
echo "---------------------------------"
read -r -p "Escolha o caso (número): " jdx; jdx=$((jdx-1))
if [ "$jdx" -lt 0 ] || [ "$jdx" -ge "${#cases[@]}" ]; then
  echo "❌ Opção inválida."; sleep 2; exit 1
fi
case_name="${cases[$jdx]}"
CASE_DIR="$CASE_ROOT/$case_name"

cd "$CASE_DIR" || { echo "❌ Falha ao entrar em $CASE_DIR"; sleep 2; exit 1; }

echo ""
echo "⚠️  Será realizada a limpeza de artefatos numéricos:"
echo "    • diretórios de tempo numéricos (exceto '0' e '0.orig' se existirem)"
echo "    • diretórios 'processor*' (decomposição paralela)"
echo "    • diretório 'postProcessing/'"
echo "    • arquivos de log: log.*, log.pre"
echo ""
read -r -p "Confirmar limpeza em '$CASE_DIR'? [s/N]: " resp; resp="${resp,,}"
if [[ "$resp" != "s" && "$resp" != "sim" && "$resp" != "y" && "$resp" != "yes" ]]; then
  echo "↩️  Operação cancelada."; sleep 1
else
  # ───────── Substituição da limpeza: agora 100% Bash, sem find -regex ─────────
  shopt -s nullglob

  # Remove tempos numéricos (1, 2, 3, 10, 11, 0.1, 0.01, 12.5, etc.), mantendo 0 e 0.orig
  for d in *; do
    if [[ -d "$d" && "$d" != "0" && "$d" != "0.orig" && "$d" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      rm -rf -- "$d"
    fi
  done

  # Remove processor*
  rm -rf -- processor* 2>/dev/null || true

  # Remove pós-processamento
  rm -rf -- postProcessing 2>/dev/null || true

  # Remove logs
  rm -f -- log.* log.pre 2>/dev/null || true

  shopt -u nullglob
  # ─────────────────────────────────────────────────────────────────────────────

  echo "✅ Limpeza concluída em: $CASE_DIR"
fi

echo ""
read -r -p "Pressione ENTER para voltar ao menu do OpenFOAM..." _
if [ -n "${AESC_ROOT:-}" ] && [ -f "$AESC_ROOT/src/openfoam/menu_openfoam.sh" ]; then
  bash "$AESC_ROOT/src/openfoam/menu_openfoam.sh"
else
  bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
fi
