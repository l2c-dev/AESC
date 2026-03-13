
# 🛩️ Ambiente de Execução – XFOIL (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **XFOIL** do AESC (Ambientes de Execução de Simulações Científicas) foi desenvolvido para gerenciar de forma integrada a execução de análises aerodinâmicas utilizando o software **XFOIL**, um código clássico amplamente utilizado para análise de perfis aerodinâmicos em regime subsônico.

O ambiente organiza tanto **execuções individuais** quanto **varreduras paramétricas**, permitindo automatizar:

- execução de casos individuais
- campanhas de varredura (Reynolds ou Mach)
- pós-processamento automático
- organização estruturada dos resultados

Todos os scripts seguem o padrão visual e operacional do AESC e utilizam o arquivo global `etc/env.sh` para detecção automática dos diretórios do sistema.

---

# 📁 Estrutura de Scripts

| Script | Função principal |
|------|----------------|
| `menu_xfoil.sh` | Menu principal do ambiente XFOIL dentro do AESC. |
| `executar_caso.sh` | Executa uma simulação individual para um perfil NACA especificado. |
| `pos_processar_caso.sh` | Realiza o pós-processamento de um caso único já executado. |
| `executar_varredura.sh` | Executa uma campanha de varredura paramétrica (Reynolds ou Mach). |
| `pos_processar_varredura.sh` | Realiza o pós-processamento de campanhas de varredura. |
| `limpar_simulacoes.sh` | Remove resultados de simulações ou campanhas completas. |

---

# 📁 Estrutura do Código

O código fonte do XFOIL fica localizado em:

```
codes/xfoil
```

Neste diretório estão incluídos:

| Script | Função |
|------|-------|
| `install.sh` | Compila o código fonte do XFOIL. |
| `Allrun.sh` | Executa uma análise aerodinâmica individual. |
| `Allsweep.sh` | Executa campanhas de varredura paramétrica. |
| `Allpos.sh` | Realiza pós-processamento de casos únicos. |
| `Allsweep_pos.sh` | Realiza pós-processamento de campanhas. |
| `Allclean.sh` | Limpa arquivos temporários do código. |

---

# 🔁 Fluxo de Trabalho Típico

Um fluxo típico de utilização do ambiente XFOIL dentro do AESC é:

### 1️⃣ Executar caso único

Utilizar a opção:

```
Executar caso único
```

O sistema solicitará:

- perfil NACA
- número de Reynolds
- número de Mach
- número máximo de iterações

Os resultados serão armazenados em:

```
simulations/xfoil/single_runs/
```

---

### 2️⃣ Pós-processar caso único

Utilizar a opção:

```
Pós-processar caso único
```

O sistema executará scripts Python para gerar:

- gráficos aerodinâmicos
- arquivos processados
- dados organizados

---

### 3️⃣ Executar varredura paramétrica

Utilizar a opção:

```
Executar varredura
```

A varredura pode ser realizada em:

- Reynolds
- Mach

Os resultados são armazenados em:

```
simulations/xfoil/sweeps/
```

---

### 4️⃣ Pós-processar varredura

Utilizar a opção:

```
Pós-processar varredura
```

O sistema gera automaticamente:

- gráficos comparativos
- tabelas consolidadas
- visualizações da campanha

---

### 5️⃣ Limpar simulações

A opção **Limpar simulações** permite remover:

- execuções individuais
- campanhas completas

mantendo o diretório do ambiente organizado.

---

# 📦 Dependências do Sistema

Para compilar e executar o XFOIL no ambiente AESC, é necessário instalar:

### Ubuntu / Debian

```bash
sudo apt install gfortran libx11-dev libxext-dev xvfb python3 python3-venv
```

Dependências:

| Pacote | Função |
|------|------|
| `gfortran` | compilador Fortran |
| `libx11-dev` | biblioteca gráfica necessária para compilação |
| `libxext-dev` | extensão do X11 |
| `xvfb` | servidor X virtual utilizado em ambientes sem interface gráfica |
| `python3-venv` | criação de ambientes virtuais Python |

---

# 🐍 Ambiente Python para Pós-processamento

Os scripts de pós-processamento utilizam Python e as bibliotecas:

```
numpy
matplotlib
pandas
```

O ambiente virtual Python é criado automaticamente em:

```
codes/xfoil/.venv
```

Caso o ambiente não exista, os scripts do AESC oferecem criar automaticamente o ambiente e instalar as dependências necessárias.

---

# 🖥 Execução em Ambientes Sem Interface Gráfica

O XFOIL depende de bibliotecas gráficas X11.  
Para permitir execução em servidores sem interface gráfica, os scripts utilizam:

```
xvfb-run
```

que cria um **servidor gráfico virtual**, permitindo que o XFOIL execute normalmente em terminais remotos.

---

# 📁 Estrutura de Diretórios

```
AESC
│
├── codes
│   └── xfoil
│       ├── install.sh
│       ├── Allrun.sh
│       ├── Allsweep.sh
│       ├── Allpos.sh
│       └── Allsweep_pos.sh
│
├── simulations
│   └── xfoil
│       ├── single_runs
│       └── sweeps
│
└── src
    └── xfoil
        ├── menu_xfoil.sh
        ├── executar_caso.sh
        ├── pos_processar_caso.sh
        ├── executar_varredura.sh
        ├── pos_processar_varredura.sh
        └── limpar_simulacoes.sh
```

---

# 🇬🇧 Description (English)

The **XFOIL environment** in AESC (Scientific Simulation Execution Environments) provides an integrated workflow to run aerodynamic analyses using **XFOIL**, a widely used classical solver for subsonic airfoil analysis.

The environment supports both:

- single-case simulations
- parametric sweeps

while automatically managing:

- execution
- data organization
- post-processing
- visualization

All scripts follow the AESC structure and load global configuration variables from `etc/env.sh`.

---

# 🔁 Typical Workflow

1. Run a **single airfoil simulation**
2. Perform **post-processing**
3. Run **parameter sweeps** (Re or Mach)
4. Generate **campaign plots**
5. Clean simulation folders

---

# 🤝 Credits

Desenvolvido por  
**Prof. Rafael Gabler Gontijo**

**L2C – Soluções em Computação Científica**
