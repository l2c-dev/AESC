#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Diretórios relativos
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Caminho via env.sh (apenas para exibir na ajuda)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"
SIMS_SIMMSUS="$SIMS_BASE/simmsus"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║          Ambiente de execução – SIMMSUS 🧲 | Ajuda e informações             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📘 Este ambiente foi especialmente preparado para a execução de simulações"
echo "    com o código open source *SIMMSUS*, voltado à modelagem de sistemas de"
echo "    partículas magnéticas sujeitas a forças de interação de longo alcance."
echo ""
echo "🌐 Estrutura geral esperada:"
echo "  - 📁 As simulações devem estar organizadas em pastas dentro de:"
echo "       $SIMS_SIMMSUS/"
echo "  - 📄 Cada pasta deve conter ao menos um arquivo obrigatório:"
echo "       simconfig.dat  ← arquivo de configuração da simulação"
echo ""
echo "⚙️  Para executar uma simulação:"
echo "  1. Compile o código SIMMSUS"
echo "  2. Crie uma pasta em $SIMS_SIMMSUS/nome_do_caso"
echo "  3. Inclua nessa pasta o arquivo simconfig.dat correspondente"
echo "  4. Execute a simulação por meio dos menus do AESC"
echo ""
echo "📂 Pasta de exemplo incluída no sistema:"
echo "  Nome:  field_oscil_brown_noshear_n3000_vf05"
echo ""
echo "  🔬 Essa simulação está configurada para:"
echo "    - 5 realizações simultâneas"
echo "    - 3000 partículas magnéticas"
echo "    - Fração volumétrica de 5%"
echo "    - Ambiente Browniano (inclui efeitos térmicos)"
echo "    - Ação de campo externo oscilatório"
echo "    - Sem cisalhamento ativado"
echo ""
echo "🧩 O nome da pasta reflete alguns parâmetros da simulação, seguindo o padrão:"
echo "     field_oscil_brown_noshear_n3000_vf05"
echo "     └── campo oscilatório | browniano | sem cisalhamento | n = 3000 | vf = 5%"
echo ""
echo "✏️  O arquivo 'simconfig.dat' pode ser editado manualmente para configurar:"
echo "    - Número de partículas, tempo total, delta t"
echo "    - Tipo de simulação (Browniana, com ou sem campo, com ou sem cisalha)"
echo "    - Parâmetros físicos do sistema, entre outras informações"
echo ""
echo "🔖 Sugestão:"
echo "    - Mantenha a lógica de nomeação das pastas para boa organização."
echo "    - Copie a pasta exemplo como base para novas simulações."
echo "    - Altere o simconfig.dat dentro de novas pastas conforme necessário."
echo ""
read -p "Pressione ENTER para retornar ao menu SIMMSUS..."
exec bash "$SCRIPT_DIR/menu_simmsus.sh"
