#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Diretórios relativos e caminhos via env.sh
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"

COD_DIR="$CODES_BASE/pinn"
SIM_DIR="$SIMS_BASE/pinn"

while true; do
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
  echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
  echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║              Ambiente de execução – PINN 🤖 | Monitorar simulação            ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""

  # Verifica se diretório de simulações existe
  if [[ ! -d "$SIM_DIR" ]]; then
    echo "❌ Diretório de simulações PINN não encontrado: $SIM_DIR"
    read -r -p "Pressione ENTER para retornar ao menu PINN..."
    exec bash "$SCRIPT_DIR/menu_pinn.sh"
  fi

  # Mapa: índice → "PID|OUTDIR|CMD"
  MAPA=()
  INDEX=0

  # Lista processos python do usuário atual
  RAW_PROCESS_LIST=$(ps aux | grep '[p]ython')

  if [[ -n "$RAW_PROCESS_LIST" ]]; then
    while read -r linha; do
      # Usuário e PID
      usuario=$(echo "$linha" | awk '{print $1}')
      pid=$(echo "$linha" | awk '{print $2}')

      # Só processos do próprio usuário
      [[ "$usuario" != "$USER" ]] && continue

      # Verifica se /proc/$pid existe
      [[ ! -r "/proc/$pid/environ" ]] && continue

      # Filtra pelo executável real: precisa ser python*
      exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null) || continue
      base_exe=$(basename "$exe")
      [[ "$base_exe" != python* ]] && continue

      # Lê AESC_OUTDIR do ambiente do processo
      env_outdir=$(tr '\0' '\n' < "/proc/$pid/environ" | grep '^AESC_OUTDIR=' | head -n1 | cut -d= -f2-)

      # Só interessa se o processo tiver AESC_OUTDIR apontando para SIM_DIR
      if [[ -z "$env_outdir" ]]; then
        continue
      fi
      if [[ "$env_outdir" != "$SIM_DIR"* ]]; then
        continue
      fi

      # Comando completo
      cmd=$(ps -p "$pid" -o args= 2>/dev/null)
      [[ -z "$cmd" ]] && continue

      MAPA[$INDEX]="$pid|$env_outdir|$cmd"
      ((INDEX++))
    done <<< "$RAW_PROCESS_LIST"
  fi

  if [[ ${#MAPA[@]} -eq 0 ]]; then
    echo "⚠️ Nenhuma simulação PINN em execução foi encontrada para o usuário '$USER'."
    echo ""
    read -r -p "Pressione ENTER para retornar ao menu PINN..."
    exec bash "$SCRIPT_DIR/menu_pinn.sh"
  fi

  echo "📡 Simulações PINN em execução encontradas:"
  echo ""
  for i in "${!MAPA[@]}"; do
    entry="${MAPA[$i]}"
    pid="${entry%%|*}"
    rest="${entry#*|}"
    outdir="${rest%%|*}"
    cmd="${rest#*|}"

    base_case="$(basename "$outdir")"
    echo " [$i] 🤖 PID $pid | 📁 $base_case"
    echo "      🧾 log.treino em: $outdir/log.treino"
    echo "      🧠 cmd: $cmd"
    echo ""
  done

  RET_IDX=${#MAPA[@]}
  echo " [$RET_IDX] 🔙 Voltar ao menu PINN"
  echo ""
  read -r -p "Digite o número da simulação que deseja gerenciar: " escolha

  # Voltar ao menu PINN
  if [[ "$escolha" == "$RET_IDX" ]]; then
    echo "🔙 Retornando ao menu PINN..."
    sleep 0.5
    exec bash "$SCRIPT_DIR/menu_pinn.sh"
  fi

  # Validação
  if ! [[ "$escolha" =~ ^[0-9]+$ ]] || (( escolha < 0 || escolha >= ${#MAPA[@]} )); then
    echo "❌ Opção inválida."
    read -r -p "Pressione ENTER para continuar..."
    continue
  fi

  SELECIONADO="${MAPA[$escolha]}"
  PID="${SELECIONADO%%|*}"
  rest="${SELECIONADO#*|}"
  OUTDIR="${rest%%|*}"
  LOGFILE="$OUTDIR/log.treino"

  # Submenu para o processo selecionado
  while true; do
    echo ""
    echo "🧠 Processo selecionado:"
    echo " PID:   $PID"
    echo " Pasta: $OUTDIR"
    echo " Log:   $LOGFILE"
    echo ""
    echo " [1] 📄 Ver últimas 20 linhas de log.treino"
    echo " [2] 🛑 Encerrar simulação (kill $PID)"
    echo " [0] 🔙 Voltar à lista de simulações"
    echo ""
    read -r -p "Escolha uma ação: " acao

    case "$acao" in
      1)
        echo ""
        if [[ -f "$LOGFILE" ]]; then
          echo "📄 Últimas 20 linhas de $LOGFILE:"
          echo "────────────────────────────────────────────"
          tail -n 20 "$LOGFILE"
          echo "────────────────────────────────────────────"
        else
          echo "⚠️ Arquivo de log não encontrado:"
          echo "   $LOGFILE"
        fi
        echo ""
        read -r -p "Pressione ENTER para retornar ao monitoramento deste processo..."
        ;;
      2)
        if kill "$PID" 2>/dev/null; then
          echo "🛑 Processo $PID encerrado."
        else
          echo "⚠️ Não foi possível encerrar o processo $PID (talvez já tenha terminado)."
        fi
        read -r -p "Pressione ENTER para retornar à lista de simulações..."
        break
        ;;
      0)
        echo "🔙 Retornando à lista de simulações PINN..."
        sleep 0.5
        break
        ;;
      *)
        echo "❌ Opção inválida."
        ;;
    esac
  done
done
