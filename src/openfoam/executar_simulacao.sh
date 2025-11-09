#!/bin/bash

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║              Ambiente de execução – OpenFOAM 🌀 | Executar Caso              ║"
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
  # Compatibilidade com caminho antigo
  # shellcheck disable=SC1091
  source /usr/lib/openfoam/openfoam2412/etc/bashrc
fi

# ─────────────────────────── Diretório de simulações ───────────────────────────
# Preferir env.sh (simulations/), mantendo compat com 'simulacoes/'
if [ -n "${AESC_SIMS_DIR:-}" ] && [ -d "$AESC_SIMS_DIR/openfoam" ]; then
  SIMS_DIR="$AESC_SIMS_DIR/openfoam"
else
  # Fallback relativo ao script
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
  echo "   Estrutura esperada: simulations/openfoam/<solver>/<case>"
  sleep 3
  exit 1
fi

# ─────────────────────────── Seleção do solver ─────────────────────────────────
echo "📦 Solvers com casos disponíveis:"
echo "---------------------------------"
solvers=()
while IFS= read -r -d '' d; do
  s="$(basename "$d")"
  solvers+=("$s")
done < <(find "$SIMS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "${#solvers[@]}" -eq 0 ]; then
  echo "ℹ️  Nenhum solver encontrado em: $SIMS_DIR"
  sleep 2
  exit 0
fi

for i in "${!solvers[@]}"; do
  printf " [%d] %s\n" "$((i+1))" "${solvers[$i]}"
done
echo "---------------------------------"
read -r -p "Escolha o solver (número): " idx
idx=$((idx-1))
if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#solvers[@]}" ]; then
  echo "❌ Opção inválida."
  sleep 2
  exit 1
fi
solver="${solvers[$idx]}"

# ─────────────────────────── Seleção do caso ───────────────────────────────────
CASE_ROOT="$SIMS_DIR/$solver"
echo ""
echo "📁 Casos para o solver '$solver':"
echo "---------------------------------"
cases=()
while IFS= read -r -d '' d; do
  c="$(basename "$d")"
  cases+=("$c")
done < <(find "$CASE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "${#cases[@]}" -eq 0 ]; then
  echo "ℹ️  Nenhum caso encontrado em: $CASE_ROOT"
  sleep 2
  exit 0
fi

for i in "${!cases[@]}"; do
  printf " [%d] %s\n" "$((i+1))" "${cases[$i]}"
done
echo "---------------------------------"
read -r -p "Escolha o caso (número): " jdx
jdx=$((jdx-1))
if [ "$jdx" -lt 0 ] || [ "$jdx" -ge "${#cases[@]}" ]; then
  echo "❌ Opção inválida."
  sleep 2
  exit 1
fi
case_name="${cases[$jdx]}"

CASE_DIR="$CASE_ROOT/$case_name"

# ─────────────────────────── Execução: Allpre → Allrun ────────────────────────
cd "$CASE_DIR" || { echo "❌ Falha ao entrar em $CASE_DIR"; exit 1; }

echo ""
echo "🔧 Verificando scripts de caso..."
ALLPRE="./Allpre"
ALLRUN="./Allrun"

# Se não estiverem executáveis, chamar via bash
ALLPRE_CMD="$ALLPRE"
ALLRUN_CMD="$ALLRUN"
[ -x "$ALLPRE" ] || ALLPRE_CMD="bash $ALLPRE"
[ -x "$ALLRUN" ] || ALLRUN_CMD="bash $ALLRUN"

if [ ! -f "$ALLPRE" ] || [ ! -f "$ALLRUN" ]; then
  echo "❌ Esperado encontrar Allpre e Allrun em: $CASE_DIR"
  sleep 2
  exit 1
fi

echo ""
echo "🧹 Preparando pré-processamento (Allpre) → log.pre"
sleep 1
# Allpre em primeiro plano
bash -lc "$ALLPRE_CMD" > log.pre 2>&1
pre_status=$?

if [ "$pre_status" -ne 0 ]; then
  echo "❌ Erro no Allpre (status $pre_status). Veja log.pre"
  sleep 2
  exit 1
fi

# Nome do log principal
RUN_LOG="log.$solver"

# Detecta se o Allrun é estilo OpenFOAM (gera o próprio log: RunFunctions/foamRun/foamJob)
if grep -Eq 'RunFunctions|foamRun|foamJob|log\.' "$ALLRUN"; then
  # Se já existir log.<solver>, rotaciona para evitar a mensagem "already run"
  if [ -f "$RUN_LOG" ]; then
    ts="$(date +%Y%m%d-%H%M%S)"
    mv -f "$RUN_LOG" "$RUN_LOG.prev-$ts"
  fi

  echo ""
  echo "🚀 Iniciando simulação (Allrun estilo OpenFOAM) – logs geridos pelo Allrun"
  sleep 1
  # Dispara em background; o próprio Allrun cria/atualiza log.<solver>
  nohup bash -lc "$ALLRUN_CMD" >/dev/null 2>&1 &
  run_pid=$!
else
  # Modo genérico: nós gerimos o log
  echo ""
  echo "🚀 Iniciando simulação (Allrun genérico) → $RUN_LOG (nohup, background)"
  sleep 1
  nohup bash -lc "$ALLRUN_CMD" > "$RUN_LOG" 2>&1 &
  run_pid=$!
fi

echo ""
echo "✅ Simulação iniciada!"
echo "   • Solver:   $solver"
echo "   • Caso:     $case_name"
echo "   • Pasta:    $CASE_DIR"
if [ -f "$RUN_LOG" ]; then
  echo "   • Log:      $CASE_DIR/$RUN_LOG"
else
  echo "   • Log:      gerido pelo Allrun (veja arquivos log.* neste diretório)"
fi
echo "   • PID:      $run_pid"
echo ""
echo "Dica: para acompanhar logs:"
if [ -f "$RUN_LOG" ]; then
  echo "  tail -f \"$CASE_DIR/$RUN_LOG\""
else
  echo "  ls -ltr log.*     # veja o(s) arquivo(s) gerado(s) pelo Allrun"
  echo "  tail -f log.mhtFoam   # por exemplo"
fi
echo ""

read -r -p "Pressione ENTER para voltar ao menu do OpenFOAM..." _

# Volta ao menu OpenFOAM (usa AESC_ROOT quando disponível; fallback para BASE_DIR)
if [ -n "${AESC_ROOT:-}" ] && [ -f "$AESC_ROOT/src/openfoam/menu_openfoam.sh" ]; then
  bash "$AESC_ROOT/src/openfoam/menu_openfoam.sh"
else
  bash "$BASE_DIR/src/openfoam/menu_openfoam.sh"
fi
