#!/bin/bash
# Ajuda e boas práticas (offline)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

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
read -p "Pressione ENTER para retornar ao menu Git..."
bash "$SCRIPT_DIR/menu_git.sh"; exit 0
