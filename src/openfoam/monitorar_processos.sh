#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

while true; do
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║         🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas        ║"
  echo "║               💻 Laboratório Pessoal de Computação Científica                ║"
  echo "║                 Desenvolvido por Prof. Rafael Gabler Gontijo                 ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║        Ambiente de execução – OpenFOAM 🌀 | Monitoramento de processos       ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
  echo ""
  echo "🔍 Buscando simulações OpenFOAM em execução..."

  # Encontra todos os processos com solvers OpenFOAM ativos
  processes=$(ps aux | grep Foam | grep -v "grep")
  IFS=$'\n'
  index=1
  declare -A pid_map

  if [[ -z "$processes" ]]; then
    echo "⚠️  Nenhuma simulação em execução encontrada."
  else
    echo "💻 Simulações encontradas:"
    echo "────────────────────────────────────────────────────────────────────────────"

    for line in $processes; do
      user=$(echo "$line" | awk '{print $1}')
      pid=$(echo "$line" | awk '{print $2}')
      command=$(echo "$line" | awk '{for(i=11;i<=NF;++i)printf $i" "; print ""}')
      solver=$(basename "$command")

      # Verifica se o PID ainda existe
      if ! ps -p "$pid" > /dev/null; then
        continue
      fi

      case_path=$(pwdx "$pid" 2>/dev/null | awk '{print $2}')
      [[ -z "$case_path" ]] && case_path="Desconhecido"

      start=$(LANG=C ps -p "$pid" -o lstart=)
      start_epoch=$(date -d "$start" +%s 2>/dev/null)
      now_epoch=$(date +%s)
      if [[ -n "$start_epoch" ]]; then
        elapsed_seconds=$((now_epoch - start_epoch))
        elapsed=$(date -ud "@$elapsed_seconds" +%T)
      else
        elapsed="??:??:??"
      fi

      echo "$index) 👤 Usuário: $user | 🔢 PID: $pid"
      echo "    📁 Local: $case_path"
      echo "    🕒 Tempo decorrido: $elapsed"
      echo "    📄 Log: log.$solver"
      echo "────────────────────────────────────────────────────────────────────────────"

      pid_map[$index]="$pid|$solver|$case_path"
      index=$((index + 1))
    done
  fi

  echo ""
  echo "0) 🔙 Voltar ao menu OpenFOAM"

  read -p "Digite o número do processo que deseja monitorar ou '0' para voltar: " choice

  if [[ "$choice" == "0" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/menu_openfoam.sh"
    exit 0
  fi

  entry="${pid_map[$choice]}"
  if [[ -z "$entry" ]]; then
    echo "❌ Número inválido. Pressione Enter para continuar..."
    read
    continue
  fi

  IFS='|' read -r pid solver case_path <<< "$entry"
  log_file="$case_path/log.$solver"
  log_file="${log_file%"${log_file##*[![:space:]]}"}"

  echo ""
  echo "🧭 Opções disponíveis:"
  echo "1) Monitorar últimas 20 linhas do log"
  echo "2) Encerrar o processo"
  read -p "Escolha a opção desejada (1 ou 2): " action

  case "$action" in
    1)
      echo ""
      echo "📡 Monitorando log '$log_file'..."
      echo "──────────────────────────────────────────────────────"
      if [[ -f "$log_file" ]]; then
        tail -n 20 "$log_file"
      else
        echo "❌ Arquivo de log '$log_file' não encontrado."
      fi
      ;;
    2)
      kill "$pid" && echo "🛑 Processo $pid encerrado com sucesso." || echo "❌ Falha ao encerrar o processo."
      ;;
    *)
      echo "❌ Opção inválida."
      ;;
  esac

  echo ""
  read -p "Pressione Enter para retornar ao monitoramento..."
done
