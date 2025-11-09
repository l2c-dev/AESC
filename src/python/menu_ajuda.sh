#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Ajuda – Python Científico (AESC)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Caminhos via env.sh (com fallbacks)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"
# Fallbacks legados:
[[ -d "$AESC_ROOT/codigos" && ! -d "$CODES_BASE" ]] && CODES_BASE="$AESC_ROOT/codigos"
[[ -d "$AESC_ROOT/simulacoes" && ! -d "$SIMS_BASE" ]] && SIMS_BASE="$AESC_ROOT/simulacoes"

COD_DIR="$CODES_BASE/python"
SIM_DIR="$SIMS_BASE/python"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║             Ambiente – Python Científico 🐍 | Ajuda & Convenções             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

cat <<TXT
📌 Estrutura
- Códigos:      $COD_DIR
- Simulações:   $SIM_DIR

🧩 Dependências (registradas p/ instalador futuro)
- pandas, numpy, matplotlib, scikit-learn
- opcional: ambiente virtual em ${AESC_PY_SCI_VENV:-~/venvs/python-sci}

⚙️ Execução (fluxo)
1) Coloque seu projeto em $COD_DIR (ex.: MLRM-MHT/MLRM-MHT.py + CSVs).
2) No menu Python Científico, escolha "Executar código" e selecione o .py.
3) O script é executado no diretório do projeto.
   - Se o script criar uma pasta de saída (ou escrever em \$AESC_OUTDIR), ela será movida para $SIM_DIR.
   - Se não criar pasta, os arquivos gerados/modificados serão organizados em "mlrun_<timestamp>" e movidos para $SIM_DIR.
4) Use "Limpar simulação" para remover pastas (com confirmação).

📖 Convenções
- Os scripts Python devem escrever resultados no próprio diretório do projeto
  (o AESC moverá/organizará a saída para simulacoes/python).
- Recomenda-se incluir timestamp no nome da pasta de saída.

💡 Dicas
- Crie um requirements (ex.: codes/python/requirements.txt) para reprodutibilidade.
- Venv sugerido: ${AESC_PY_SCI_VENV:-~/venvs/python-sci}
  Ativar: source ${AESC_PY_SCI_VENV:-~/venvs/python-sci}/bin/activate
TXT

echo ""
read -r -p "Pressione ENTER para retornar ao menu Python Científico..." _
exec bash "$SCRIPT_DIR/menu_python.sh"
