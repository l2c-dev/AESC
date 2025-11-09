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
echo "║             Git 🧰 | Gerar/atualizar README.md (wizard OFFLINE)              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

read -r -p "📁 Caminho do projeto (ex.: ../codes/meu_projeto ou ../codigos/meu_projeto): " PROJ
[[ -z "$PROJ" ]] && { echo "❌ Caminho vazio."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }

PROJ="${PROJ/#\~/$HOME}"
PROJ="$(readlink -f "$PROJ")"

if [[ ! -d "$PROJ" ]]; then
  echo "❌ Diretório não existe: $PROJ"
  read -r -p "ENTER..." _
  exec bash "$SCRIPT_DIR/menu_git.sh"
fi

if [[ ! -d "$PROJ/.git" ]]; then
  echo "⚠️  Aviso: $PROJ não parece ser um repositório git (sem .git)."
  read -r -p "Deseja continuar mesmo assim? [s/N]: " cont
  [[ ! "$cont" =~ ^[Ss]$ ]] && exec bash "$SCRIPT_DIR/menu_git.sh"
fi

echo ""
read -r -p "📝 Título do projeto: " TIT
read -r -p "🧠 Resumo curto (1-3 linhas): " RESUMO
read -r -p "🔬 Contexto científico (ex.: fenômeno, equações, modelos): " CONTEXTO
read -r -p "🔧 Dependências (ex.: pip/apt/module load): " DEP
read -r -p "▶️  Como executar (comandos principais): " EXEC
read -r -p "📂 Organização dos dados/resultados (onde salvar/ler): " ORG
read -r -p "👥 Autores (nome/afiliação/contato): " AUT
read -r -p "📜 Licença (ex.: MIT, BSD-3, Apache-2.0, ou vazio): " LIC

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
  read -r -p "Deseja fazer commit desta atualização agora? [S/n]: " do_commit
  if [[ ! "$do_commit" =~ ^[Nn]$ ]]; then
    cd "$PROJ" && git add README.md && git commit -m "docs: atualiza README via AESC (wizard offline)" >/dev/null 2>&1
    echo "✅ Commit realizado."
  fi
fi

read -r -p "Pressione ENTER para retornar ao menu Git..." _
exec bash "$SCRIPT_DIR/menu_git.sh"
