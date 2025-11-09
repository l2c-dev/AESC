
# 🧠 Ambiente de Execução – PINN (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **PINN** do AESC (Ambientes de Execução de Simulações Científicas) foi criado para facilitar a execução e gerenciamento de simulações baseadas em **Physics-Informed Neural Networks (PINNs)** utilizando **Python e PyTorch**.  
Ele permite testar e comparar diferentes configurações de redes neurais aplicadas à solução de equações diferenciais, de forma integrada ao sistema AESC.

Os scripts deste ambiente seguem o padrão modular do sistema e carregam automaticamente as variáveis definidas em `etc/env.sh`, garantindo portabilidade e consistência entre diferentes ambientes de execução.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_pinn.sh` | Menu principal do ambiente PINN. Centraliza a execução e limpeza das simulações. |
| `executar_codigo.sh` | Executa o script Python PINN selecionado, armazenando automaticamente os resultados em `simulacoes/PINN/`. |
| `limpar_simulacao.sh` | Exibe e permite remover pastas de simulações PINN antigas, com confirmação. |

### 🔁 Fluxo de Trabalho Típico

1. **Escolher o script** – através de `menu_pinn.sh`, acessando a opção de execução.  
2. **Executar simulação** – via `executar_codigo.sh`, que solicita parâmetros e executa o script Python PINN correspondente.  
3. **Armazenar resultados** – automaticamente, o sistema cria uma nova pasta em `simulacoes/PINN/<nome_do_codigo>/<caso_timestamp>/` contendo:  
   - Arquivos de saída `.vtk`  
   - Gráficos `.png` das funções de perda e campos calculados  
   - Arquivo `parametros.json` com os parâmetros utilizados  
4. **Limpar simulações antigas** – através de `limpar_simulacao.sh`, mantendo o diretório organizado.

### ⚙️ Organização de Diretórios

```
aesc/
├── codes/PINN/                  → Códigos-fonte em Python (ex.: cavidade_cisalhante.py)
├── simulations/PINN/            → Resultados das simulações PINN
│    └── cavidade_cisalhante/
│         ├── caso_20250701-123045/
│         │    ├── parametros.json
│         │    ├── loss_total.png
│         │    ├── campo_u.png
│         │    ├── campo_v.png
│         │    ├── campo_p.png
│         │    └── resultados.vtk
└── etc/env.sh                   → Variáveis de ambiente globais
```

### 🧩 Integração e Portabilidade

- Todos os caminhos de execução e salvamento são definidos de forma **relativa**, com base em `$AESC_ROOT` do `env.sh`.  
- O ambiente é compatível com qualquer instalação Python ≥ 3.9 com **PyTorch**, **Matplotlib** e **NumPy** instalados.  
- Pode ser integrado a sistemas de execução paralela ou a menus interativos (ex.: via `screen` ou `tmux`).

### 💡 Observações

- Os scripts PINN foram projetados para gerar resultados **reprodutíveis**, salvando automaticamente os parâmetros e gráficos.  
- A troca de otimizadores e funções de ativação é parametrizada dentro dos próprios scripts Python, conforme solicitado durante a execução.  
- As simulações podem ser rodadas localmente ou remotamente (ex.: no nó de cálculo `parmenides`).

---

## 🇬🇧 Description (English)

The **PINN environment** in AESC (Scientific Simulation Execution Environments) enables running and managing simulations based on **Physics-Informed Neural Networks (PINNs)** using **Python and PyTorch**.  
It provides an integrated workflow to test different neural network configurations applied to differential equation problems.

All scripts load configuration variables from `etc/env.sh`, ensuring portability and consistent folder management across environments.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_pinn.sh` | Main menu for the PINN environment. |
| `executar_codigo.sh` | Runs the selected Python PINN script and stores results in `simulacoes/PINN/`. |
| `limpar_simulacao.sh` | Lists and removes old simulation folders with confirmation. |

### 🔁 Typical Workflow

1. **Select a script** – via `menu_pinn.sh`.  
2. **Run the simulation** – using `executar_codigo.sh`, which requests inputs and runs the corresponding Python PINN.  
3. **Save outputs automatically** – results are organized in `simulacoes/PINN/<code_name>/<case_timestamp>/`, including:  
   - `.vtk` result files  
   - `.png` plots for loss functions and flow fields  
   - `parametros.json` file with input parameters  
4. **Clean old simulations** – with `limpar_simulacao.sh` to maintain organization.

### ⚙️ Directory Layout

```
aesc/
├── codes/PINN/                  → Python source codes (e.g., cavidade_cisalhante.py)
├── simulations/PINN/            → Simulation results
│    └── cavidade_cisalhante/
│         ├── case_20250701-123045/
│         │    ├── parametros.json
│         │    ├── loss_total.png
│         │    ├── campo_u.png
│         │    ├── campo_v.png
│         │    ├── campo_p.png
│         │    └── resultados.vtk
└── etc/env.sh                   → Global environment variables
```

### 🧩 Integration and Portability

- All execution paths are **relative** to `$AESC_ROOT` defined in `env.sh`.  
- Compatible with any Python ≥ 3.9 installation with **PyTorch**, **Matplotlib**, and **NumPy**.  
- Can be adapted for remote execution (e.g., on compute nodes like `parmenides`).

### 💡 Notes

- PINN scripts automatically store parameters and plots to ensure **reproducibility**.  
- Optimizer and activation changes are handled inside each Python script as user inputs.  
- Designed for both local and remote execution.

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica  
