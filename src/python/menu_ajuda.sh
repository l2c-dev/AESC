#!/bin/bash
# Ajuda – Python Científico (AESC)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
COD_DIR="$(readlink -f "$ROOT_DIR/../codigos/python")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/python")"

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
- opcional: ambiente virtual em ~/venvs/python-sci

⚙️ Execução (fluxo)
1) Coloque seu projeto em $COD_DIR (ex.: MLRM-MHT/MLRM-MHT.py + CSVs).
2) No menu Python Científico, escolha "Executar código" e selecione o .py.
3) O script é executado no diretório do projeto.
   - Se o script criar uma pasta de saída, ela será movida para $SIM_DIR.
   - Se não criar pasta, os arquivos gerados/modificados serão organizados em "mlrun_<timestamp>" e movidos para $SIM_DIR.
4) Use "Limpar simulação" para remover pastas (com confirmação).

📖 Convenções
- Os scripts Python devem escrever resultados no próprio diretório do projeto
  (o AESC moverá a pasta criada/organizada para simulacoes/python).
- Recomenda-se incluir timestamp no nome da pasta de saída.

💡 Dicas
- Crie um requirements (ex.: codigos/python/requirements-python.txt) para reprodutibilidade.
- Se quiser usar venv: python3 -m venv ~/venvs/python-sci; source ~/venvs/python-sci/bin/activate; pip install ...

TXT

echo ""
read -p "Pressione ENTER para retornar ao menu Python Científico..."
bash "$SCRIPT_DIR/menu_python.sh"; exit 0
