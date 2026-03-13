#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

imprimir_cabecalho() {
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
  echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
  echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║                        Ambiente de execução – XFOIL 🛩️                        ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
}

imprimir_cabecalho

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] 🛩️  Executar caso único"
  echo " [2] 📊 Pós-processar caso único"
  echo " [3] 🌪️  Executar varredura"
  echo " [4] 📈 Pós-processar varredura"
  echo " [5] 🧹 Limpar simulações"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -p "Digite a opção desejada: " opcao

  case "$opcao" in
    1) exec bash "$SCRIPT_DIR/executar_caso.sh" ;;
    2) exec bash "$SCRIPT_DIR/pos_processar_caso.sh" ;;
    3) exec bash "$SCRIPT_DIR/executar_varredura.sh" ;;
    4) exec bash "$SCRIPT_DIR/pos_processar_varredura.sh" ;;
    5) exec bash "$SCRIPT_DIR/limpar_simulacoes.sh" ;;
    0)
      echo "🔙 Voltando ao menu principal..."
      sleep 0.3
      exit 0
      ;;
    *)
      echo "❌ Opção inválida."
      sleep 0.8
      imprimir_cabecalho
      ;;
  esac
done
