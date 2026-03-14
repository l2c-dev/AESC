
# 🧪 AESC – Ambientes de Execução de Simulações Científicas

[![L2C](https://img.shields.io/badge/L2C-Soluções%20em%20Computação%20Científica-blue)](https://www.l2c.dev.br)

---

## 🇧🇷 Sobre o Projeto

O **AESC** é um "mini sistema operacional via terminal" desenvolvido em **Bash**, modular e portável, para organização e execução de simulações científicas em diferentes ambientes.  
Ele foi projetado para ser simples, robusto e extensível, permitindo que estudantes e pesquisadores possam:

- Organizar códigos e simulações em uma estrutura clara 📂  
- Compilar, executar, monitorar e limpar simulações a partir de menus interativos 🧭  
- Padronizar fluxos de trabalho científicos e educativos 👨‍🏫  
- Compartilhar repositórios e exemplos reproduzíveis 🌍  

A proposta é unir **código aberto** e **práticas modernas** de organização em um só ambiente de execução.

---

## 🇬🇧 About the Project

**AESC** is a modular, portable **terminal-based mini operating system** developed in Bash, designed to organize and execute scientific simulations across multiple environments.  
It enables students and researchers to:

- Keep codes and simulations in a clean, standardized directory structure 📂  
- Compile, run, monitor, and clean simulations via interactive menus 🧭  
- Standardize scientific and educational workflows 👨‍🏫  
- Share reproducible repositories and ready-to-use examples 🌍  

The philosophy behind AESC is to bring **open-source tools** and **scientific reproducibility** together in a simple yet powerful terminal interface.

---

## 📂 Estrutura de Diretórios / Directory Structure

A organização do sistema segue sempre caminhos **relativos** ao diretório raiz (ex.: `/mnt/dados/l2c`):

```
AESC/
├── src/                     # Scripts Bash do sistema (menus e utilitários)
│   ├── aesc.sh              # Launcher principal
│   ├── openfoam/            # Ambiente OpenFOAM
│   ├── simmsus/             # Ambiente SIMMSUS (Fortran)
│   ├── pinn/                # Ambiente PINN (PyTorch)
│   ├── python/              # Ambiente Python científico
│   ├── octave/              # Ambiente Octave
│   ├── xfoil/               # Ambiente XFOIL (análise aerodinâmica)
│   └── git/                 # Ambiente de integração com Git/GitHub
│
├── codigos/                 # Códigos-fonte
│   ├── openfoam/
│   ├── simmsus/
│   ├── pinn/
│   ├── python/
│   ├── octave/
│   └── xfoil/
│
├── simulacoes/              # Resultados de simulação
│   ├── openfoam/
│   ├── simmsus/
│   ├── pinn/
│   ├── python/
│   ├── octave/
│   └── xfoil/
│
└── docs/                    # Documentação e exemplos futuros
```

---

## 🌐 Ambientes de Execução / Execution Environments

- **OpenFOAM 🌀** – Compilação, execução e monitoramento de casos CFD  
- **SIMMSUS 🧲** – Código Fortran para partículas magnéticas em fluidos  
- **PINNs 🤖** – Redes Neurais Informadas por Física (PyTorch + VTK)  
- **Python Científico 🐍** – Scripts de análise de dados e machine learning  
- **Octave 📉** – Problemas numéricos clássicos com GNU Octave  
- **XFOIL 🛩️** – Análise aerodinâmica de perfis utilizando o solver clássico XFOIL  
- **Git 🧰** – Criação e clonagem de repositórios científicos  

Cada ambiente possui menus próprios, mantendo a **mesma estética e lógica operacional**.  
Todos os scripts usam caminhos relativos, garantindo portabilidade entre diferentes máquinas.

---

## ⚙️ Como Executar / How to Run

1. Clone este repositório para a sua máquina:

```bash
git clone https://github.com/l2c-dev/AESC.git
```

2. Acesse o diretório e dê permissão de execução:

```bash
cd AESC
find src -type f -name "*.sh" -exec chmod +x {} \;
```

3. Edite seu arquivo `~/.bashrc` e adicione um **alias** para facilitar:

```bash
alias aesc='/src/aesc.sh'
```

> Ajuste o caminho conforme o local onde você instalou o AESC.

4. Recarregue seu bashrc:

```bash
source ~/.bashrc
```

5. Agora basta digitar:

```bash
aesc
```

e o menu principal será carregado 🎉

---

## 🤝 Créditos

Projeto desenvolvido por **Prof. Rafael Gabler Gontijo** no contexto da  
[**L2C – Soluções em Computação Científica**](https://www.l2c.dev.br).

A L2C atua em consultoria, treinamento e desenvolvimento de software científico baseado em **open source**, com foco em **simulação computacional científica**.
