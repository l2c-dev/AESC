#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/.." && pwd)"   # este script em src/, raiz é um nível acima
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Caminhos globais via env.sh (com fallbacks)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"

OPENFOAM_SIM_DIR="$SIMS_BASE/openfoam"
SIMMSUS_SIM_DIR="$SIMS_BASE/simmsus"
PINN_SIM_DIR="$SIMS_BASE/pinn"

# Caminhos para monitores específicos
OPENFOAM_MON="$AESC_ROOT/src/openfoam/monitorar_processos.sh"
SIMMSUS_MON="$AESC_ROOT/src/simmsus/monitorar_simulacao.sh"
PINN_MON="$AESC_ROOT/src/pinn/monitorar_simulacao.sh"

contar_openfoam() {
  local count=0
  for pid in $(pgrep -u "$USER" 'Foam' 2>/dev/null); do
    local cwd
    cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null) || continue
    [[ "$cwd" == "$OPENFOAM_SIM_DIR"* ]] && ((count++))
  done
  echo "$count"
}

contar_simmsus() {
  local count=0
  for pid in $(pgrep -u "$USER" 'simmsus.ex' 2>/dev/null); do
    local cwd
    cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null) || continue
    [[ "$cwd" == "$SIMMSUS_SIM_DIR"* ]] && ((count++))
  done
  echo "$count"
}

contar_pinn() {
  local count=0
  local RAW
  RAW=$(ps aux | grep '[p]ython') || RAW=""
  [[ -z "$RAW" ]] && { echo 0; return; }

  while read -r linha; do
    local usuario pid exe base_exe env_outdir
    usuario=$(echo "$linha" | awk '{print $1}')
    pid=$(echo "$linha" | awk '{print $2}')
    [[ "$usuario" != "$USER" ]] && continue
    [[ ! -r "/proc/$pid/environ" ]] && continue

    exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null) || continue
    base_exe=$(basename "$exe")
    [[ "$base_exe" != python* ]] && continue

    env_outdir=$(tr '\0' '\n' < "/proc/$pid/environ" | grep '^AESC_OUTDIR=' | head -n1 | cut -d= -f2-)
    [[ -z "$env_outdir" ]] && continue
    [[ "$env_outdir" != "$PINN_SIM_DIR"* ]] && continue

    ((count++))
  done <<< "$RAW"

  echo "$count"
}

while true; do
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
  echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
  echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║                  Monitoramento global de simulações em execução              ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""

  OF_COUNT=$(contar_openfoam)
  SM_COUNT=$(contar_simmsus)
  PN_COUNT=$(contar_pinn)

  echo "📊 Resumo de processos em execução (usuário: $USER)"
  echo ""
  printf " [1] 🌊 OpenFOAM     → %2d simulação(ões)\n" "$OF_COUNT"
  printf " [2] 🧲 SIMMSUS      → %2d simulação(ões)\n" "$SM_COUNT"
  printf " [3] 🤖 PINN         → %2d simulação(ões)\n" "$PN_COUNT"
  echo  " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -r -p "Escolha um ambiente para detalhes/gerenciamento: " opt

  case "$opt" in
    1)
      if [[ "$OF_COUNT" -eq 0 ]]; then
        echo ""
        echo "⚠️ Nenhuma simulação OpenFOAM em execução para o usuário '$USER'."
        read -r -p "Pressione ENTER para continuar..."
      else
        if [[ -x "$OPENFOAM_MON" ]]; then
          bash "$OPENFOAM_MON"
        else
          echo "❌ Script de monitoramento OpenFOAM não encontrado em: $OPENFOAM_MON"
          read -r -p "Pressione ENTER para continuar..."
        fi
      fi
      ;;
    2)
      if [[ "$SM_COUNT" -eq 0 ]]; then
        echo ""
        echo "⚠️ Nenhuma simulação SIMMSUS em execução para o usuário '$USER'."
        read -r -p "Pressione ENTER para continuar..."
      else
        if [[ -x "$SIMMSUS_MON" ]]; then
          bash "$SIMMSUS_MON"
        else
          echo "❌ Script de monitoramento SIMMSUS não encontrado em: $SIMMSUS_MON"
          read -r -p "Pressione ENTER para continuar..."
        fi
      fi
      ;;
    3)
      if [[ "$PN_COUNT" -eq 0 ]]; then
        echo ""
        echo "⚠️ Nenhuma simulação PINN em execução para o usuário '$USER'."
        read -r -p "Pressione ENTER para continuar..."
      else
        if [[ -x "$PINN_MON" ]]; then
          bash "$PINN_MON"
        else
          echo "❌ Script de monitoramento PINN não encontrado em: $PINN_MON"
          read -r -p "Pressione ENTER para continuar..."
        fi
      fi
      ;;
    0)
      echo "🔙 Voltando ao menu principal do AESC..."
      sleep 0.4
      exit 0
      ;;
    *)
      echo "❌ Opção inválida."
      read -r -p "Pressione ENTER para continuar..."
      ;;
  esac
done
