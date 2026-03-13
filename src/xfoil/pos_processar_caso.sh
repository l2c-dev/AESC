#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codigos}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulacoes}"

CASOS_DIR="$SIMS_BASE/xfoil/single_runs"
ALLPOS="$CODES_BASE/xfoil/Allpos.sh"
VENV_DIR="$CODES_BASE/xfoil/.venv"
VENV_PYTHON="$VENV_DIR/bin/python"
VENV_PIP="$VENV_DIR/bin/pip"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║            Ambiente de execução – XFOIL 🛩️ | Pós-processar caso               ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$CASOS_DIR" ]]; then
  echo "❌ Diretório de casos não encontrado:"
  echo "   $CASOS_DIR"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

if [[ ! -x "$ALLPOS" ]]; then
  echo "❌ Script Allpos.sh não encontrado ou sem permissão:"
  echo "   $ALLPOS"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

# ─────────────────────────── Garantia do ambiente Python ───────────────────────
if [[ ! -x "$VENV_PYTHON" ]]; then
  echo "❌ Ambiente Python não encontrado."
  echo "   Esperado em:"
  echo "   $VENV_DIR"
  echo ""
  read -p "Deseja criar o ambiente automaticamente agora? (s/n): " RESP

  if [[ "$RESP" =~ ^[Ss]$ ]]; then
    echo ""
    echo "🐍 Criando ambiente virtual Python..."
    python3 -m venv "$VENV_DIR" || {
      echo "❌ Falha ao criar o ambiente virtual."
      read -p "Pressione [Enter] para retornar..."
      bash "$SCRIPT_DIR/menu_xfoil.sh"
      exit 1
    }

    echo "📦 Instalando dependências..."
    "$VENV_PIP" install --upgrade pip || {
      echo "❌ Falha ao atualizar o pip."
      read -p "Pressione [Enter] para retornar..."
      bash "$SCRIPT_DIR/menu_xfoil.sh"
      exit 1
    }

    "$VENV_PIP" install numpy matplotlib pandas || {
      echo "❌ Falha ao instalar numpy/matplotlib/pandas."
      read -p "Pressione [Enter] para retornar..."
      bash "$SCRIPT_DIR/menu_xfoil.sh"
      exit 1
    }

    echo ""
    echo "✅ Ambiente Python criado com sucesso."
    echo ""
  else
    echo ""
    echo "⚠️ Operação cancelada."
    echo "Para criar manualmente, execute:"
    echo ""
    echo "cd $CODES_BASE/xfoil"
    echo "python3 -m venv .venv"
    echo ".venv/bin/pip install --upgrade pip"
    echo ".venv/bin/pip install numpy matplotlib pandas"
    echo ""
    read -p "Pressione [Enter] para retornar..."
    bash "$SCRIPT_DIR/menu_xfoil.sh"
    exit 1
  fi
fi
# ────────────────────────────────────────────────────────────────────────────────

mapfile -t CASOS < <(find "$CASOS_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

if [[ ${#CASOS[@]} -eq 0 ]]; then
  echo "⚠️  Nenhum caso encontrado."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 0
fi

echo "📁 Casos disponíveis:"
echo ""
for i in "${!CASOS[@]}"; do
  echo " [$i] 📁 ${CASOS[$i]}"
done
echo " [${#CASOS[@]}] 🔙 Voltar ao menu XFOIL"
echo ""

read -p "Digite o número do caso que deseja pós-processar: " ESCOLHA

if [[ "$ESCOLHA" == "${#CASOS[@]}" ]]; then
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 0
fi

if ! [[ "$ESCOLHA" =~ ^[0-9]+$ ]] || (( ESCOLHA < 0 || ESCOLHA >= ${#CASOS[@]} )); then
  echo "❌ Opção inválida."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

CASO="${CASOS[$ESCOLHA]}"
CASO_DIR="$CASOS_DIR/$CASO"

echo ""
echo "🚀 Pós-processando caso:"
echo "   $CASO_DIR"
echo ""

bash "$ALLPOS" "$CASO_DIR"

echo ""
read -p "🔁 Deseja pós-processar outro caso? (s/n): " RESPOSTA
if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
  bash "$SCRIPT_DIR/pos_processar_caso.sh"
else
  bash "$SCRIPT_DIR/menu_xfoil.sh"
fi
