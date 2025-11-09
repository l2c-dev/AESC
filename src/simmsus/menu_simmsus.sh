#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Diretório em que esse script se encontra
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Diretório raiz (se precisar no futuro)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

imprimir_cabecalho() {
  clear
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
  echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
  echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
  echo "╠══════════════════════════════════════════════════════════════════════════════╣"
  echo "║                      Ambiente de execução – SIMMSUS 🧲                       ║"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
}

imprimir_cabecalho

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] 🛠️  Compilar a versão mais recente do código SIMMSUS"
  echo " [2] 📘 Assistente de criação de arquivo de configuração"
  echo " [3] 🧪 Executar simulação com base em simconfig.dat existente"
  echo " [4] 🧹 Limpar simulação (preserva simconfig.dat)"
  echo " [5] 📡 Monitorar simulação em andamento"
  echo " [6] 📘 Ajuda: estrutura de pastas e nomenclatura"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -p "Digite a opção desejada: " opcao

  case "$opcao" in
    1) exec bash "$SCRIPT_DIR/compilar_codigo.sh" ;;
    2) exec bash "$SCRIPT_DIR/gerar_simconfig.sh" ;;
    3) exec bash "$SCRIPT_DIR/executar_simulacao.sh" ;;
    4) exec bash "$SCRIPT_DIR/limpar_simulacao.sh" ;;
    5) exec bash "$SCRIPT_DIR/monitorar_simulacao.sh" ;;
    6) exec bash "$SCRIPT_DIR/menu_ajuda.sh" ;;
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
