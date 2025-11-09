#!/bin/bash
# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do [ -f "$_aesc_env" ] && . "$_aesc_env" && break; done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Criar estrutura mínima de projeto científico + git init + primeiro commit (OFFLINE)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Base de códigos via env.sh, com fallback
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
[[ -d "$AESC_ROOT/codigos" && ! -d "$CODES_BASE" ]] && CODES_BASE="$AESC_ROOT/codigos"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║           Git 🧰 | Iniciar repositório científico (template mínimo)          ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "❌ git não encontrado. Instale-o (ex.: sudo apt install -y git)."
  read -r -p "Pressione ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_git.sh"
fi

read -r -p "📛 Nome do projeto (sem espaços, use _ ou -): " PROJ
[[ -z "$PROJ" ]] && { echo "❌ Nome vazio."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }

DEST_DIR_DEFAULT="$CODES_BASE/$PROJ"
echo "📁 Diretório destino padrão: $DEST_DIR_DEFAULT"
read -r -p "Deseja usar esse destino? [S/n]: " use_def
if [[ "$use_def" =~ ^[Nn]$ ]]; then
  read -r -p "Informe outro diretório de destino: " DUSER
  DEST_DIR="${DUSER/#\~/$HOME}"
  DEST_DIR="$(readlink -f "$DEST_DIR")"
else
  DEST_DIR="$DEST_DIR_DEFAULT"
fi

if [[ -e "$DEST_DIR" && -n "$(ls -A "$DEST_DIR" 2>/dev/null)" ]]; then
  echo "❌ O diretório já existe e não está vazio: $DEST_DIR"
  read -r -p "Pressione ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_git.sh"
fi

# Linguagens para .gitignore
echo ""
echo "🧩 Selecione linguagens/ambientes para .gitignore (separe por vírgulas):"
echo "  1) Python"
echo "  2) C++"
echo "  3) Fortran"
echo "  4) Octave/Matlab"
echo "  5) Geral (logs, temporários)"
read -r -p "Sua escolha (ex.: 1,5): " LSEL

# Licença
echo ""
echo "📜 Selecione a licença:"
echo "  1) MIT"
echo "  2) BSD-3-Clause"
echo "  3) Apache-2.0"
echo "  4) Sem licença por agora"
read -r -p "Opção: " LIC

mkdir -p "$DEST_DIR"/{src,data,results,docs} || { echo "❌ Falha ao criar estrutura."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }

# .gitignore mínimo
GITIGNORE="$DEST_DIR/.gitignore"
touch "$GITIGNORE"
IFS=',' read -r -a CHOICES <<< "$LSEL"
for opt in "${CHOICES[@]}"; do
  case "$(echo "$opt" | xargs)" in
    1) cat >> "$GITIGNORE" <<'PY'
# Python
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/
ENV/
env/
.ipynb_checkpoints/
PY
    ;;
    2) cat >> "$GITIGNORE" <<'CPP'
# C++
*.o
*.obj
*.out
*.exe
build/
CMakeFiles/
CMakeCache.txt
cppcache/
CPP
    ;;
    3) cat >> "$GITIGNORE" <<'F90'
# Fortran
*.o
*.mod
*.out
*.exe
build/
F90
    ;;
    4) cat >> "$GITIGNORE" <<'M'
# Octave/Matlab
*.asv
*.mex*
octave-workspace
M
    ;;
    5) cat >> "$GITIGNORE" <<'GEN'
# Geral
*.log
*.tmp
*.bak
.DS_Store
thumbs.db
GEN
    ;;
  esac
done

# LICENSE
case "$LIC" in
  1) cat > "$DEST_DIR/LICENSE" <<'MIT'
MIT License
Copyright (c) YEAR AUTHOR
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
MIT
     ;;
  2) cat > "$DEST_DIR/LICENSE" <<'BSD'
BSD 3-Clause License
Copyright (c) YEAR, AUTHOR
All rights reserved.
Redistribution and use in source and binary forms...
BSD
     ;;
  3) cat > "$DEST_DIR/LICENSE" <<'AP2'
Apache License 2.0
Copyright YEAR AUTHOR
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License...
AP2
     ;;
  *) : ;; # sem licença agora
esac

# README mínimo (será refinado no gerar_readme.sh)
cat > "$DEST_DIR/README.md" <<EOF
# $PROJ

Projeto científico iniciado via AESC.

## Estrutura
- \`src/\`: código-fonte
- \`data/\`: dados (entrada/auxiliares)
- \`results/\`: resultados (figuras, tabelas, logs)
- \`docs/\`: documentação

## Como começar
1. Adapte este README usando o menu: Git → "Gerar/atualizar README.md"
2. Versão inicial criada automaticamente.
EOF

# Git init + primeiro commit
cd "$DEST_DIR" || { echo "❌ Falha ao acessar $DEST_DIR"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_git.sh"; }
git init >/dev/null 2>&1
git add -A
git commit -m "feat: projeto científico iniciado via AESC (estrutura mínima)" >/dev/null 2>&1

echo ""
echo "✅ Projeto criado em: $DEST_DIR"
echo "📦 Estrutura mínima pronta e commit inicial realizado."
echo ""
read -r -p "Pressione ENTER para retornar ao menu Git..." _
exec bash "$SCRIPT_DIR/menu_git.sh"
