
# 📉 Ambiente de Execução – Octave (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **Octave** do AESC (Ambientes de Execução de Simulações Científicas) foi desenvolvido para permitir a execução automatizada de **scripts numéricos** escritos em **GNU Octave** (ou MATLAB compatível), com organização automática dos resultados e integração total ao sistema AESC.

Todos os scripts utilizam o arquivo global `etc/env.sh` para detecção de caminhos e variáveis, assegurando portabilidade entre diferentes instalações.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_octave.sh` | Menu principal do ambiente Octave, integrando as opções de execução e limpeza. |
| `executar_codigo.sh` | Executa um script `.m` localizado em `codes/octave`, organiza automaticamente as saídas e as move para `simulations/octave`. |
| `limpar_simulacao.sh` | Exibe todas as simulações salvas em `simulations/octave` e permite sua remoção com confirmação. |

### 🔁 Fluxo de Trabalho Típico

1. **Executar script** – via `menu_octave.sh`, selecionando o código `.m` desejado.  
2. **Rodar simulação** – `executar_codigo.sh` identifica automaticamente novas pastas ou arquivos gerados pelo script.  
3. **Organizar resultados** – os dados são movidos automaticamente para `simulacoes/octave/<nome_da_execução>`.
4. **Limpar simulações antigas** – `limpar_simulacao.sh` remove pastas de execução antigas, mantendo o ambiente limpo.

### ⚙️ Organização de Diretórios

```
aesc/
├── codes/octave/                → Scripts .m para execução
│    └── exemplo_ajuste_curva.m
├── simulations/octave/          → Resultados das execuções
│    └── ajuste_curva_20250701-101200/
│         ├── figure1.png
│         ├── dados_saida.txt
│         └── relatorio.pdf
└── etc/env.sh                   → Variáveis de ambiente globais
```

### 🧩 Integração e Portabilidade

- O ambiente usa **GNU Octave** (≥ 7.0), mas é compatível com scripts MATLAB.  
- Todos os caminhos são configurados dinamicamente via `$AESC_ROOT`.  
- A detecção de saídas é automática — o sistema move os diretórios recém-criados para `simulations/octave`.  
- Suporte a execução interativa e scripts com geração de gráficos e relatórios.

### 💡 Observações

- A execução ocorre diretamente no terminal, exibindo as saídas do Octave em tempo real.  
- Os logs de execução e resultados são organizados automaticamente, sem necessidade de edição manual.  
- O AESC reconhece pastas criadas dinamicamente e as transfere para o diretório de simulações.  

---

## 🇬🇧 Description (English)

The **Octave environment** in AESC (Scientific Simulation Execution Environments) automates the execution of **numerical scripts** written in **GNU Octave** (or MATLAB-compatible syntax), managing results and directory structure automatically.

All scripts load configuration variables from `etc/env.sh`, ensuring portability across different installations.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_octave.sh` | Main menu integrating all Octave-related operations. |
| `executar_codigo.sh` | Runs a `.m` script from `codes/octave`, organizing and moving results to `simulations/octave`. |
| `limpar_simulacao.sh` | Lists and removes simulation folders with confirmation. |

### 🔁 Typical Workflow

1. **Select and execute a script** – via `menu_octave.sh`.  
2. **Run simulation** – `executar_codigo.sh` automatically detects new folders or files created by the script.  
3. **Organize outputs** – results are moved automatically to `simulations/octave/<execution_name>`.  
4. **Clean old runs** – `limpar_simulacao.sh` removes old simulation folders with confirmation.

### ⚙️ Directory Layout

```
aesc/
├── codes/octave/                → .m scripts for execution
│    └── curve_fit_example.m
├── simulations/octave/          → Results of Octave runs
│    └── curve_fit_20250701-101200/
│         ├── figure1.png
│         ├── output_data.txt
│         └── report.pdf
└── etc/env.sh                   → Global environment variables
```

### 🧩 Integration and Portability

- Uses **GNU Octave ≥ 7.0**, fully compatible with MATLAB scripts.  
- Execution and path management are dynamic and relative to `$AESC_ROOT`.  
- Automatically detects new folders or modified files and moves them to the simulation directory.  
- Supports interactive plots and automated reporting.

### 💡 Notes

- Octave runs directly in the terminal with live output.  
- Results and logs are automatically organized into the correct simulation folder.  
- The system recognizes and moves dynamically created folders to maintain order.  

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica  
