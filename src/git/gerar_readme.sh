#!/bin/bash
# Wizard OFFLINE para gerar/atualizar README.md em um projeto já existente

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║             Git 🧰 | Gerar/atualizar README.md (wizard OFFLINE)              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

read -p "📁 Caminho do projeto (ex.: ../codigos/meu_projeto): " PROJ
[[ -z "$PROJ" ]] && { echo "❌ Caminho vazio."; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_git.sh"; exit 1; }

PROJ="${PROJ/#\~/$HOME}"
PROJ="$(readlink -f "$PROJ")"

if [[ ! -d "$PROJ" ]]; then
  echo "❌ Diretório não existe: $PROJ"
  read -p "ENTER..." ; bash "$SCRIPT_DIR/menu_git.sh"; exit 1
fi

if [[ ! -d "$PROJ/.git" ]]; then
  echo "⚠️  Aviso: $PROJ não parece ser um repositório git (sem .git)."
  read -p "Deseja continuar mesmo assim? [s/N]: " cont
  [[ ! "$cont" =~ ^[Ss]$ ]] && { bash "$SCRIPT_DIR/menu_git.sh"; exit 0; }
fi

echo ""
read -p "📝 Título do projeto: " TIT
read -p "🧠 Resumo curto (1-3 linhas): " RESUMO
read -p "🔬 Contexto científico (ex.: fenômeno, equações, modelos): " CONTEXTO
read -p "🔧 Dependências (ex.: pip/apt/module load): " DEP
read -p "▶️  Como executar (comandos principais): " EXEC
read -p "📂 Organização dos dados/resultados (onde salvar/ler): " ORG
read -p "👥 Autores (nome/afiliação/contato): " AUT
read -p "📜 Licença (ex.: MIT, BSD-3, Apache-2.0, ou vazio): " LIC

README="$PROJ/README.md"
cat > "$README" <<EOF
# $TIT

$RESUMO

## Contexto científico
$CONTEXTO

## Dependências
$DEP

## Como executar
\`\`\`bash
$EXEC
\`\`\`

## Estrutura de pastas
- \`src/\`: código-fonte
- \`data/\`: dados (entrada/auxiliares)
- \`results/\`: resultados (figuras, tabelas, logs)
- \`docs/\`: documentação

## Organização dos dados/resultados
$ORG

## Autores
$AUT

## Licença
$LIC
EOF

echo ""
echo "✅ README.md atualizado em: $README"

if command -v git >/dev/null 2>&1 && [[ -d "$PROJ/.git" ]]; then
  read -p "Deseja fazer commit desta atualização agora? [S/n]: " do_commit
  if [[ ! "$do_commit" =~ ^[Nn]$ ]]; then
    cd "$PROJ" && git add README.md && git commit -m "docs: atualiza README via AESC (wizard offline)" >/dev/null 2>&1
    echo "✅ Commit realizado."
  fi
fi

read -p "Pressione ENTER para retornar ao menu Git..."
bash "$SCRIPT_DIR/menu_git.sh"; exit 0
