#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Diretórios relativos
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                Ambiente de execução – PINN 🤖 | Navier–Stokes                ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] ▶️  Executar código PINN"
  echo " [2] 🧹 Limpar simulação"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -r -p "Digite a opção desejada: " opcao

  case "$opcao" in
    1) exec bash "$SCRIPT_DIR/executar_codigo.sh" ;;
    2) exec bash "$SCRIPT_DIR/limpar_simulacao.sh" ;;
    0)
      echo "🔙 Voltando ao menu principal..."
      sleep 0.3
      exit 0
      ;;
    *)
      echo "❌ Opção inválida. Tente novamente."
      sleep 0.8
      clear
      ;;
  esac
done
