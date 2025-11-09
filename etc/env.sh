# =========================
# AESC - Configuração global
# =========================

# Raiz do projeto (auto-detect se não vier de fora)
if [ -z "${AESC_ROOT:-}" ]; then
  # Tenta resolver a partir deste arquivo
  _AESC_ENV_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  export AESC_ROOT="$(cd "$_AESC_ENV_DIR/.." && pwd)"
  unset _AESC_ENV_DIR
fi

# --- nomes de pastas (padrão em inglês) ---
export AESC_CODES_NAME="${AESC_CODES_NAME:-codes}"
export AESC_SIMS_NAME="${AESC_SIMS_NAME:-simulations}"

# Diretórios canônicos
export AESC_CODES_DIR="${AESC_CODES_DIR:-$AESC_ROOT/$AESC_CODES_NAME}"
export AESC_SIMS_DIR="${AESC_SIMS_DIR:-$AESC_ROOT/$AESC_SIMS_NAME}"

# --- OpenFOAM ---
# ajuste aqui se usar outra versão/caminho
export AESC_OPENFOAM_BASHRC="${AESC_OPENFOAM_BASHRC:-/opt/openfoam2412/etc/bashrc}"

# --- Python (científico) ---
export AESC_PY_SCI_VENV="${AESC_PY_SCI_VENV:-$HOME/venvs/python-sci}"
export AESC_PY_CMD="${AESC_PY_CMD:-python3}"

# --- Conveniências ---
# Pasta de logs opcional (não usado pelos scripts atuais; reservado)
export AESC_LOGS_DIR="${AESC_LOGS_DIR:-$AESC_ROOT/logs}"
