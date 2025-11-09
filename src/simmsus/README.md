
# 🧲 Ambiente de Execução – SIMMSUS (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **SIMMSUS** do AESC (Ambientes de Execução de Simulações Científicas) foi desenvolvido para gerenciar de forma integrada o ciclo completo de simulações utilizando o código **SIMMSUS** — um software científico em Fortran voltado ao estudo de suspensões magnéticas e sistemas particulados com interação de longo alcance.

Todos os scripts deste ambiente seguem o padrão visual e operacional do AESC e utilizam o arquivo de configuração global `etc/env.sh` para detecção automática dos diretórios do sistema.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_simmsus.sh` | Menu principal do ambiente SIMMSUS, integrando todas as funções. |
| `compilar_codigo.sh` | Faz o download (ou atualização) do repositório SIMMSUS e compila o código usando **ifx** (Intel Fortran) ou **gfortran**. |
| `gerar_simconfig.sh` | Executa o gerador interativo de arquivos `simconfig.dat`, que define os parâmetros físicos e numéricos da simulação. |
| `executar_simulacao.sh` | Roda o executável `simmsus.ex` em segundo plano, registrando a saída em `log.simmsus`. |
| `monitorar_simulacao.sh` | Lista as simulações em andamento, exibe logs em tempo real e permite encerrar processos ativos. |
| `limpar_simulacao.sh` | Limpa as pastas de simulação, preservando apenas o arquivo de configuração `simconfig.dat`. |
| `menu_ajuda.sh` | Exibe informações sobre a estrutura de pastas, convenções de nomeação e parâmetros típicos de simulação. |

### 🔁 Fluxo de Trabalho Típico

1. **Compilar o código** – via `compilar_codigo.sh`, que cria o executável `simmsus.ex` em `codes/simmsus/`.
2. **Gerar configuração** – com `gerar_simconfig.sh`, que cria o arquivo `simconfig.dat` em uma nova pasta de simulação.
3. **Executar simulação** – via `executar_simulacao.sh`, que inicia o cálculo em segundo plano.
4. **Monitorar execução** – através do `monitorar_simulacao.sh`, para observar o progresso e encerrar se necessário.
5. **Limpar pastas** – usando `limpar_simulacao.sh`, preservando apenas arquivos essenciais.

### 🧠 Integração com o Repositório Oficial

O código **SIMMSUS** não está incluído neste repositório AESC.  
Os scripts fazem **clone automático** do projeto público hospedado em:

👉 [https://github.com/lcec-unb/simmsus](https://github.com/lcec-unb/simmsus)

Caso o diretório `codes/simmsus/` não exista, o script de compilação solicitará o clone automaticamente.

---

## 🇬🇧 Description (English)

The **SIMMSUS environment** in AESC (Scientific Simulation Execution Environments) manages the full workflow for running simulations with the **SIMMSUS** code — a Fortran-based scientific solver designed to study magnetic suspensions and particle systems with long-range interactions.

All scripts follow AESC’s standardized structure and automatically load global environment variables from `etc/env.sh` to ensure portability across installations.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_simmsus.sh` | Central menu for the SIMMSUS environment, linking all utilities. |
| `compilar_codigo.sh` | Downloads (or updates) the SIMMSUS repository and compiles the code using **ifx** or **gfortran**. |
| `gerar_simconfig.sh` | Runs the interactive generator for `simconfig.dat`, defining the physical and numerical parameters. |
| `executar_simulacao.sh` | Launches `simmsus.ex` in the background, logging output to `log.simmsus`. |
| `monitorar_simulacao.sh` | Lists running simulations, displays logs, and allows process termination. |
| `limpar_simulacao.sh` | Cleans simulation folders, keeping only the `simconfig.dat` file. |
| `menu_ajuda.sh` | Displays information about folder structure, naming conventions, and simulation parameters. |

### 🔁 Typical Workflow

1. **Compile the code** – via `compilar_codigo.sh`, generating `simmsus.ex` under `codes/simmsus/`.
2. **Generate configuration** – with `gerar_simconfig.sh`, creating `simconfig.dat` for a new simulation folder.
3. **Run the simulation** – using `executar_simulacao.sh` (background execution).
4. **Monitor progress** – through `monitorar_simulacao.sh` for live logs or termination control.
5. **Clean up** – with `limpar_simulacao.sh`, removing outputs but keeping essential files.

### 🧲 Repository Integration

The **SIMMSUS** source code is not versioned inside AESC.  
Scripts automatically **clone the latest version** of the public repository from:

👉 [https://github.com/lcec-unb/simmsus](https://github.com/lcec-unb/simmsus)

If `codes/simmsus/` is missing, the system will request cloning during compilation.

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica 
