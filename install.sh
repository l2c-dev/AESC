#!/usr/bin/env bash
set -e

# ╭──────────────────────────────────────────────────────────────────────────────╮
# │  AESC – install.sh                                                           │
# │  Instalador de dependências + estrutura de diretórios                        │
# │  Suporta Ubuntu/Debian (apt).                                                │
# ╰──────────────────────────────────────────────────────────────────────────────╯

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║        🧪 AESC | Ambientes de Execução de Simulações Científicas             ║"
echo "║                 Instalador de dependências e estrutura                       ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║  Este script vai:                                                            ║"
echo "║   • Instalar pacotes básicos (git, build-essential, python3-venv, etc.)      ║"
echo "║   • (Opcional) Instalar Octave                                               ║"
echo "║   • Criar pastas necessárias (codes/, simulations/...)                        ║"
echo "║   • (Opcional) Criar venvs: python-sci e pinn                                ║"
echo "║   • Tornar todos os *.sh em src/ executáveis                                 ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

### AESC: BEGIN root detection (safe to re-run)
if [ -z "${AESC_ROOT:-}" ]; then
  _AESC_INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  export AESC_ROOT="$_AESC_INSTALL_DIR"
  unset _AESC_INSTALL_DIR
fi
### AESC: END root detection


# ───────────────────────────── Utilitários ─────────────────────────────────────
confirm() { # confirm "Pergunta?" -> 0=sim, 1=não
  local prompt="${1:-Confirma?} [s/N]: "
  read -r -p "$prompt" resp; resp="${resp,,}"
  [[ "$resp" == "s" || "$resp" == "sim" || "$resp" == "y" || "$resp" == "yes" ]]
}

need_sudo() {
  if [[ $EUID -ne 0 ]]; then
    echo "🔑 Algumas etapas precisam de privilégios administrativos (sudo)."
    sudo -v
  fi
}

ensure_cmd() { # ensure_cmd <cmd> <pkg-sugestao>
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "⚠️  Ferramenta '$1' não encontrada (sugestão de pacote: $2)."
    return 1
  fi
  return 0
}

# ───────────────────────────── Caminhos base ───────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
SRC_DIR="$ROOT_DIR/src"

# ───────────────────────────── Checagens básicas ───────────────────────────────
if ! command -v apt-get >/dev/null 2>&1; then
  echo "❌ Este instalador espera um sistema baseado em APT (Ubuntu/Debian)."
  echo "   Adapte os passos manualmente para sua distro."
  exit 1
fi

need_sudo

echo "📦 Atualizando índices APT..."
sudo apt-get update -y

echo "📦 Instalando pacotes essenciais..."
sudo apt-get install -y \
  git curl wget ca-certificates \
  build-essential make gfortran \
  python3 python3-venv python3-pip \
  python3-dev

# ───────────────────────────── Octave (opcional) ───────────────────────────────
if confirm "Deseja instalar o Octave (para o ambiente Octave)?"; then
  sudo apt-get install -y octave
  echo "✅ Octave instalado."
else
  echo "⏭️  Pulando instalação do Octave."
fi

# ───────────────────────────── OpenFOAM (opcional) ─────────────────────────────
echo ""
echo "ℹ️  OpenFOAM pode ser instalado de diferentes formas/versões."
echo "    Este instalador tentará instalar um pacote 'openfoam' se disponível no repositório."
echo "    Caso sua distro não tenha o pacote adequado, siga as instruções oficiais da ESI/OpenCFD."
if confirm "Tentar instalar pacote 'openfoam' via APT agora?"; then
  if sudo apt-get install -y openfoam; then
    echo "✅ OpenFOAM instalado (pacote do repositório)."
  else
    echo "⚠️  Não foi possível instalar 'openfoam' via APT."
    echo "    Siga a instalação oficial e depois adicione ao seu shell:"
    echo "    source /opt/openfoam*/etc/bashrc"
  fi
else
  echo "⏭️  Pulando tentativa automática de instalação do OpenFOAM."
fi

# ───────────────────────────── etc/env.sh (provisioning) ───────────────────────
# Cria etc/env.sh com valores padrão (não sobrescreve se já existir)
echo ""
echo "⚙️  Preparando arquivo de configuração global (etc/env.sh)..."
mkdir -p "$ROOT_DIR/etc"
if [ ! -f "$ROOT_DIR/etc/env.sh" ]; then
  cat > "$ROOT_DIR/etc/env.sh" <<'EOF'
# =========================
# AESC - Configuração global
# =========================

# Raiz do projeto (auto-detect se não vier de fora)
if [ -z "${AESC_ROOT:-}" ]; then
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
# (valor padrão compatível com os scripts atuais do projeto)
export AESC_OPENFOAM_BASHRC="${AESC_OPENFOAM_BASHRC:-/usr/lib/openfoam/openfoam2412/etc/bashrc}"

# --- Python (científico) ---
export AESC_PY_SCI_VENV="${AESC_PY_SCI_VENV:-$HOME/venvs/python-sci}"
export AESC_PY_CMD="${AESC_PY_CMD:-python3}"

# --- Conveniências ---
# Pasta de logs opcional (não usado pelos scripts atuais; reservado)
export AESC_LOGS_DIR="${AESC_LOGS_DIR:-$AESC_ROOT/logs}"
EOF
  echo "✅ etc/env.sh criado (padrões em inglês: codes/ e simulations/)."
else
  echo "ℹ️  etc/env.sh já existe — mantendo como está."
fi

# ───────────────────────────── Estrutura de diretórios ─────────────────────────
echo ""
echo "📁 Criando estrutura de diretórios do AESC..."
mkdir -p "$ROOT_DIR/codes"/{openfoam,simmsus,pinn,python,octave}
mkdir -p "$ROOT_DIR/simulations"/{openfoam,simmsus,pinn,python,octave,liggghts}
mkdir -p "$ROOT_DIR/src"/{openfoam,simmsus,pinn,python,octave,git}

# Compatibilidade com nomes anteriores em pt-BR (aliases)
[ -e "$ROOT_DIR/codigos" ]    || ln -s "codes"       "$ROOT_DIR/codigos"
[ -e "$ROOT_DIR/simulacoes" ] || ln -s "simulations" "$ROOT_DIR/simulacoes"

# Exemplos mínimos (mantém estrutura mesmo vazia)
touch "$ROOT_DIR/simulations/openfoam/.keep"
touch "$ROOT_DIR/simulations/simmsus/.keep"
touch "$ROOT_DIR/simulations/pinn/.keep"
touch "$ROOT_DIR/simulations/python/.keep"
touch "$ROOT_DIR/simulations/octave/.keep"
touch "$ROOT_DIR/simulations/liggghts/.keep"

echo "✅ Estrutura criada."

# ───────────────────────────── Permissões de execução ──────────────────────────
if [[ -d "$SRC_DIR" ]]; then
  echo ""
  echo "🔧 Tornando scripts *.sh do src/ executáveis..."
  find "$SRC_DIR" -type f -name "*.sh" -exec chmod +x {} \;
  echo "✅ Permissões ajustadas."
fi

# ───────────────────────────── VENV: python-sci (opcional) ─────────────────────
echo ""
if confirm "Criar/atualizar ambiente virtual 'python-sci' (~/$USER/venvs/python-sci) com pandas/numpy/matplotlib/scikit-learn?"; then
  PY_SCI_VENV="$HOME/venvs/python-sci"
  mkdir -p "$HOME/venvs"
  if [[ ! -d "$PY_SCI_VENV" ]]; then
    python3 -m venv "$PY_SCI_VENV"
  fi
  source "$PY_SCI_VENV/bin/activate"
  pip install --upgrade pip
  pip install pandas numpy matplotlib scikit-learn
  deactivate
  echo "✅ venv 'python-sci' pronto em $PY_SCI_VENV"
else
  echo "⏭️  Pulando criação do venv 'python-sci'."
fi

# ───────────────────────────── VENV: pinn (opcional; CPU-only) ─────────────────
echo ""
if confirm "Criar/atualizar ambiente virtual 'pinn' (~/$USER/venvs/pinn) com PyTorch (CPU), PyVista, scikit-learn, psutil, matplotlib, numpy?"; then
  PINN_VENV="$HOME/venvs/pinn"
  mkdir -p "$HOME/venvs"
  if [[ ! -d "$PINN_VENV" ]]; then
    python3 -m venv "$PINN_VENV"
  fi
  source "$PINN_VENV/bin/activate"
  pip install --upgrade pip
  # PyTorch CPU-only
  pip install torch --index-url https://download.pytorch.org/whl/cpu
  pip install pyvista scikit-learn psutil matplotlib numpy
  deactivate
  echo "✅ venv 'pinn' pronto em $PINN_VENV"
else
  echo "⏭️  Pulando criação do venv 'pinn'."
fi

# ───────────────────────────── Avisos sobre ifx / gfortran ─────────────────────
echo ""
echo "ℹ️  Compiladores:"
echo "   • GFORTRAN já foi instalado (gfortran)."
echo "   • IFX (Intel oneAPI) não é instalado automaticamente por este script."
echo "     Caso deseje usar IFX com o SIMMSUS, instale o Intel oneAPI e"
echo "     garanta que 'ifx' esteja no PATH (ex.: via setvars.sh)."

# ───────────────────────────── Conclusão ───────────────────────────────────────
echo ""
echo "🎉 Instalação/conferência concluída!"
echo "➡️  Próximos passos sugeridos:"
echo "   1) Garanta um alias para o AESC no seu ~/.bashrc, por exemplo:"
echo "      alias aesc='bash \"$(realpath "$ROOT_DIR")/src/aesc.sh\"'"
echo "   2) Abra um novo terminal e rode: aesc"
echo ""
