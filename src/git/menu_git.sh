#!/bin/bash
# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do [ -f "$_aesc_env" ] && . "$_aesc_env" && break; done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                   Ambiente de execução – Git 🧰 | Projetos                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

while true; do
  echo "🧭 Selecione uma das opções abaixo:"
  echo ""
  echo " [1] ⬇️  Clonar repositório do GitHub"
  echo " [2] 🆕 Iniciar repositório científico (template mínimo)"
  echo " [3] 📝 Gerar/atualizar README.md (wizard offline)"
  echo " [4] 📜 Menu ajuda"
  echo " [0] 🔙 Voltar ao menu principal"
  echo ""
  read -r -p "Digite a opção desejada: " opc

  case "$opc" in
    1) exec bash "$SCRIPT_DIR/clonar_repo.sh" ;;
    2) exec bash "$SCRIPT_DIR/iniciar_projeto.sh" ;;
    3) exec bash "$SCRIPT_DIR/gerar_readme.sh" ;;
    4) exec bash "$SCRIPT_DIR/menu_ajuda.sh" ;;
    0)
       echo "🔙 Voltando ao menu principal..."
       sleep 0.4
       break
       ;;
    *) echo "❌ Opção inválida. Tente novamente." ;;
  esac

  echo ""
  read -r -p "Pressione ENTER para retornar ao menu Git..." _
  clear
done
exit 0
