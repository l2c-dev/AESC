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
echo "║                     Git 🧰 | Ajuda, fluxo e boas práticas                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

cat <<'TXT'
📌 Fluxo mínimo recomendado (offline):
  1) Criar/iniciar projeto → "Iniciar repositório científico"
  2) Editar/rodar códigos em src/, colocar dados em data/ e resultados em results/
  3) Gerar/atualizar README → "Gerar/atualizar README.md"
  4) versionar:
       git add -A
       git commit -m "mensagem"
     (opcional) conectar remoto:
       git remote add origin https://github.com/usuario/repositorio.git
       git branch -M main
       git push -u origin main

📁 Estrutura mínima criada:
  <projeto>/
    ├── src/
    ├── data/
    ├── results/
    ├── docs/
    ├── .gitignore
    ├── LICENSE   (opcional)
    └── README.md (gerado/atualizado pelo wizard)

💡 Dicas:
  - Mensagens de commit curtas e informativas (imperativo curto: feat/fix/docs).
  - Use branches para features maiores.
  - README como contrato do projeto: como instalar, executar e reproduzir resultados.
TXT

echo ""
read -r -p "Pressione ENTER para retornar ao menu Git..." _
exec bash "$SCRIPT_DIR/menu_git.sh"
