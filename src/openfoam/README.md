
# 🌪️ Ambiente de Execução – OpenFOAM (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **OpenFOAM** do AESC (Ambientes de Execução de Simulações Científicas) foi desenvolvido para gerenciar todo o ciclo de trabalho com simulações de dinâmica dos fluidos computacional (**CFD**) baseadas em **OpenFOAM**, desde a compilação de solvers até o monitoramento e limpeza de casos.

Todos os scripts utilizam o arquivo de configuração global `etc/env.sh`, o que garante portabilidade e configuração automática dos caminhos de instalação.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_openfoam.sh` | Menu principal do ambiente OpenFOAM. Centraliza o acesso às demais funções. |
| `compilar_solver.sh` | Compila o solver selecionado a partir dos códigos localizados em `codes/openfoam/`. |
| `limpar_compilacao.sh` | Remove arquivos temporários de compilação (objetos `.o`, pastas `Make`, etc.). |
| `executar_simulacao.sh` | Executa um caso específico, rodando automaticamente os scripts `Allpre` e `Allrun`. |
| `monitorar_processos.sh` | Lista todas as simulações em execução, exibindo PID, tempo decorrido e logs em tempo real. |
| `limpar_caso.sh` | Limpa diretórios temporais, arquivos de log e pastas de pós-processamento de um caso específico. |

### 🔁 Fluxo de Trabalho Típico

1. **Compilar o solver** – via `compilar_solver.sh`, que gera o binário em `codes/openfoam/`.
2. **Preparar o caso** – configurar a pasta do caso em `simulations/openfoam/<solver>/<caso>`.
3. **Executar simulação** – com `executar_simulacao.sh`, que automatiza a execução dos scripts `Allpre` e `Allrun`.
4. **Monitorar simulações** – usando `monitorar_processos.sh` para acompanhar logs e encerrar execuções ativas.
5. **Limpar resultados** – através de `limpar_caso.sh` para remover diretórios temporais e arquivos de pós-processamento.
6. **Recompilar se necessário** – utilizando `limpar_compilacao.sh` seguido de `compilar_solver.sh`.

### ⚙️ Organização Padrão de Diretórios

```
aesc/
├── codes/openfoam/              → Solvers customizados
│    └── mhtFoam/
│         ├── Make/
│         └── *.C / *.H
├── simulations/openfoam/        → Casos organizados por solver
│    └── mhtFoam/
│         └── 2d_circular_tumour/
│              ├── system/
│              ├── constant/
│              ├── 0/
│              ├── Allpre.sh
│              ├── Allrun.sh
│              └── log.mhtFoam
└── etc/env.sh                   → Variáveis de ambiente globais
```

### 🧩 Integração com o Sistema

- Todos os scripts OpenFOAM do AESC são compatíveis com qualquer versão instalada.  
- O caminho da versão ativa é definido no `env.sh` através da variável:  
  ```bash
  export AESC_OPENFOAM_BASHRC="/opt/openfoam2412/etc/bashrc"
  ```
- O carregamento automático do ambiente é feito via:  
  ```bash
  source "$AESC_OPENFOAM_BASHRC"
  ```

### 💡 Observações

- O sistema é compatível tanto com casos seriais quanto paralelos (`processor*`).
- A limpeza automática preserva diretórios de tempo `0` e `0.org`.
- Os logs de execução são nomeados automaticamente conforme o solver (ex.: `log.mhtFoam`).

---

## 🇬🇧 Description (English)

The **OpenFOAM environment** in AESC (Scientific Simulation Execution Environments) provides an integrated workflow for Computational Fluid Dynamics (**CFD**) simulations based on **OpenFOAM** — from solver compilation to case monitoring and cleanup.

All scripts automatically load global environment variables from `etc/env.sh`, ensuring portability and consistent configuration across systems.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_openfoam.sh` | Central menu for the OpenFOAM environment. |
| `compilar_solver.sh` | Compiles a solver from sources located in `codes/openfoam/`. |
| `limpar_compilacao.sh` | Removes temporary build artifacts. |
| `executar_simulacao.sh` | Runs a specific case, automatically calling `Allpre` and `Allrun` scripts. |
| `monitorar_processos.sh` | Lists all running simulations, showing PID, elapsed time, and logs. |
| `limpar_caso.sh` | Cleans numerical folders, logs, and post-processing data for a selected case. |

### 🔁 Typical Workflow

1. **Compile the solver** – with `compilar_solver.sh` to generate the binary in `codes/openfoam/`.
2. **Prepare the case** – under `simulations/openfoam/<solver>/<case>`.
3. **Run simulation** – via `executar_simulacao.sh` (automatically executes `Allpre` and `Allrun`).
4. **Monitor processes** – using `monitorar_processos.sh` for logs and process control.
5. **Clean results** – with `limpar_caso.sh` to remove temporary time directories and logs.
6. **Rebuild if needed** – by running `limpar_compilacao.sh` then recompiling.

### ⚙️ Directory Layout

```
aesc/
├── codes/openfoam/              → Custom solvers
│    └── mhtFoam/
│         ├── Make/
│         └── *.C / *.H
├── simulations/openfoam/        → Simulation cases
│    └── mhtFoam/
│         └── 2d_circular_tumour/
│              ├── system/
│              ├── constant/
│              ├── 0/
│              ├── Allpre.sh
│              ├── Allrun.sh
│              └── log.mhtFoam
└── etc/env.sh                   → Global environment variables
```

### 🧩 Integration Notes

- Compatible with any OpenFOAM version.
- Version path defined in `env.sh` via:  
  ```bash
  export AESC_OPENFOAM_BASHRC="/opt/openfoam2412/etc/bashrc"
  ```
- Environment automatically sourced in all scripts.

### 💡 Remarks

- Works with both serial and parallel cases (`processor*` folders supported).
- Cleanup preserves time directories `0` and `0.org`.
- Log files automatically named after the solver (e.g., `log.mhtFoam`).

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica 
