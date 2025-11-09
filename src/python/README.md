
# 🐍 Ambiente de Execução – Python Científico (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **Python Científico** do AESC (Ambientes de Execução de Simulações Científicas) foi projetado para organizar e automatizar a execução de códigos científicos escritos em **Python**, mantendo uma estrutura padronizada para projetos, resultados e limpeza.  
Todos os scripts deste ambiente utilizam o arquivo global `etc/env.sh`, garantindo portabilidade e integração com o restante do sistema AESC.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_python.sh` | Menu principal do ambiente Python Científico. |
| `executar_codigo.sh` | Lista e executa scripts `.py` localizados em `codes/python`, detecta automaticamente pastas de saída e organiza os resultados em `simulations/python`. |
| `limpar_simulacao.sh` | Exibe todas as simulações armazenadas em `simulations/python` e permite a remoção seletiva com confirmação. |
| `menu_ajuda.sh` | Apresenta informações sobre convenções, estrutura de diretórios e boas práticas no uso do ambiente. |

### 🔁 Fluxo de Trabalho Típico

1. **Preparação**: coloque seu projeto Python em `codes/python/<nome_do_projeto>`  
   Exemplo: `codes/python/MLRM-MHT/MLRM-MHT.py`
2. **Execução**: use o menu para selecionar e rodar o código. O sistema:  
   - ativa automaticamente o ambiente virtual (`venv`) configurado em `~/venvs/python-sci` (se existir);  
   - cria uma pasta de saída nomeada como `mlrun_<timestamp>` dentro de `simulations/python`;  
   - define a variável de ambiente `AESC_OUTDIR` para que o script Python possa salvar seus resultados.  
3. **Organização dos resultados**: se o script gerar arquivos dentro de `AESC_OUTDIR`, eles serão movidos automaticamente para a pasta de simulação.  
4. **Limpeza**: o script `limpar_simulacao.sh` permite excluir simulações antigas com confirmação, mantendo o ambiente organizado.

### ⚙️ Organização de Diretórios

```
aesc/
├── codes/python/                → Códigos e projetos Python
│    └── MLRM-MHT/MLRM-MHT.py
├── simulations/python/          → Resultados das execuções
│    └── mlrun_20250701-101200/
│         ├── resultados.csv
│         ├── figura.png
│         └── log_execucao.txt
└── etc/env.sh                   → Variáveis de ambiente globais
```

### 🧩 Integração e Portabilidade

- O ambiente utiliza o Python configurado em `AESC_PY_CMD` (por padrão, `python3`), podendo também ativar um ambiente virtual definido em `AESC_PY_SCI_VENV`.  
- Todos os caminhos são relativos ao diretório raiz (`$AESC_ROOT`) e definidos no `env.sh`.  
- O sistema reconhece novas pastas criadas durante a execução e as move automaticamente para o diretório de simulações.  
- O uso de `AESC_OUTDIR` dentro dos scripts Python garante total compatibilidade com o sistema AESC.  

### 💡 Observações

- Os resultados são armazenados automaticamente, dispensando manipulação manual de pastas.  
- O uso de `AESC_OUTDIR` é recomendado para garantir a correta detecção das saídas.  
- Scripts com dependências específicas podem ser executados em ambientes virtuais configurados via `env.sh`.  

---

## 🇬🇧 Description (English)

The **Python Scientific** environment in AESC (Scientific Simulation Execution Environments) provides an automated and standardized workflow for executing and organizing **Python-based scientific projects**.  
All scripts load configuration variables from `etc/env.sh`, ensuring full portability and system integration.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_python.sh` | Main menu of the Python Scientific environment. |
| `executar_codigo.sh` | Lists and executes `.py` scripts located in `codes/python`, automatically detecting and organizing output folders under `simulations/python`. |
| `limpar_simulacao.sh` | Lists all stored simulations and allows selective deletion with confirmation. |
| `menu_ajuda.sh` | Provides information about conventions, directory structure, and best practices. |

### 🔁 Typical Workflow

1. **Preparation**: place your Python project in `codes/python/<project_name>`  
   Example: `codes/python/MLRM-MHT/MLRM-MHT.py`
2. **Execution**: use the menu to select and run your script. The system:  
   - activates the virtual environment (`venv`) configured in `~/venvs/python-sci` (if available);  
   - creates a timestamped output folder (`mlrun_<timestamp>`) inside `simulations/python`;  
   - sets the environment variable `AESC_OUTDIR` so your Python script can save outputs there.  
3. **Result Organization**: any outputs written to `AESC_OUTDIR` are automatically moved to the simulation folder.  
4. **Cleanup**: `limpar_simulacao.sh` allows you to delete old runs with confirmation, keeping the environment clean.

### ⚙️ Directory Layout

```
aesc/
├── codes/python/                → Python scripts and projects
│    └── MLRM-MHT/MLRM-MHT.py
├── simulations/python/          → Execution results
│    └── mlrun_20250701-101200/
│         ├── results.csv
│         ├── figure.png
│         └── log.txt
└── etc/env.sh                   → Global environment variables
```

### 🧩 Integration and Portability

- The environment uses the Python interpreter defined in `AESC_PY_CMD` (default `python3`) and can activate a virtual environment via `AESC_PY_SCI_VENV`.  
- All paths are relative to `$AESC_ROOT` and defined in `env.sh`.  
- Newly created folders are automatically recognized and moved to the simulation directory.  
- Using `AESC_OUTDIR` within Python scripts ensures full compatibility with the AESC system.  

### 💡 Notes

- Results are automatically stored and organized.  
- Using `AESC_OUTDIR` is recommended to ensure proper output detection.  
- Scripts with specific dependencies can be executed within virtual environments configured in `env.sh`.  

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica  
