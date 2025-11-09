
# 🧰 Ambiente de Execução – Git (AESC)

## 🇧🇷 Descrição (Português)

O ambiente **Git** do AESC (Ambientes de Execução de Simulações Científicas) fornece um conjunto de ferramentas para **gerenciar projetos científicos versionados**, permitindo criar novos repositórios, clonar projetos existentes, gerar READMEs padronizados e organizar a estrutura mínima de um repositório de pesquisa.

Todos os scripts deste ambiente utilizam o arquivo global `etc/env.sh`, garantindo portabilidade e integração com o restante do sistema AESC.

### 📁 Estrutura de Scripts

| Script | Função principal |
|--------|------------------|
| `menu_git.sh` | Menu principal do ambiente Git. |
| `clonar_repo.sh` | Clona repositórios públicos do GitHub para o diretório `codes`. |
| `iniciar_projeto.sh` | Cria a estrutura mínima de um projeto científico, inicializando um repositório Git local. |
| `gerar_readme.sh` | Assistente interativo (wizard) para gerar ou atualizar um `README.md` padronizado. |
| `menu_ajuda.sh` | Mostra boas práticas de versionamento, estrutura recomendada e fluxo de commits. |

### 🔁 Fluxo de Trabalho Típico

1. **Criação de Projeto**  
   - Use `iniciar_projeto.sh` para gerar automaticamente a estrutura básica:
     ```bash
     codes/
       └── meu_projeto/
           ├── src/
           ├── data/
           ├── results/
           ├── docs/
           ├── .gitignore
           ├── LICENSE
           └── README.md
     ```
   - O script já executa `git init` e realiza o primeiro commit (`feat: projeto científico iniciado via AESC`).

2. **Edição e Documentação**  
   - Edite o código em `src/`, insira dados em `data/` e gere resultados em `results/`.
   - Use o comando `gerar_readme.sh` para criar ou atualizar um `README.md` informativo e completo.

3. **Versionamento e Sincronização**  
   - Adicione e comite alterações normalmente:
     ```bash
     git add -A
     git commit -m "mensagem do commit"
     ```
   - Para sincronizar com o GitHub, use:
     ```bash
     git remote add origin https://github.com/usuario/repositorio.git
     git branch -M main
     git push -u origin main
     ```

4. **Clonagem de Projetos Existentes**  
   - Use `clonar_repo.sh` para baixar um repositório público do GitHub diretamente para `codes/`.
   - O script verifica dependências e confirma o destino antes da clonagem.

### ⚙️ Organização de Diretórios

```
aesc/
├── codes/                        → Projetos e repositórios científicos
│    ├── meu_projeto/
│    │    ├── src/
│    │    ├── data/
│    │    ├── results/
│    │    └── docs/
├── simulations/                  → Simulações de outros ambientes
└── etc/env.sh                    → Variáveis de ambiente globais
```

### 🧩 Integração e Portabilidade

- Todos os caminhos são relativos a `$AESC_ROOT` e definidos no arquivo `env.sh`.  
- O Git deve estar instalado e disponível no PATH do sistema (`git --version`).  
- A criação e o versionamento funcionam em modo **offline**, sem exigir conexão imediata com o GitHub.  
- O sistema utiliza convenções padronizadas para `.gitignore`, `LICENSE` e `README.md`, garantindo consistência entre projetos científicos.

### 💡 Observações

- A escolha da licença (`MIT`, `BSD-3`, `Apache-2.0`) é feita de forma interativa.  
- O assistente de README permite incluir título, contexto científico, dependências e autores.  
- O fluxo foi pensado para simplificar o uso do Git em contextos de pesquisa e simulação científica.  

---

## 🇬🇧 Description (English)

The **Git** environment in AESC (Scientific Simulation Execution Environments) provides tools for managing version-controlled scientific projects, allowing users to create repositories, clone existing ones, generate standardized READMEs, and maintain an organized research workflow.

All scripts in this environment load global settings from `etc/env.sh`, ensuring portability and system-wide consistency.

### 📁 Script Overview

| Script | Main Function |
|--------|----------------|
| `menu_git.sh` | Main menu for Git operations. |
| `clonar_repo.sh` | Clones public GitHub repositories into the `codes` directory. |
| `iniciar_projeto.sh` | Creates a minimal scientific project structure and initializes a local Git repository. |
| `gerar_readme.sh` | Interactive wizard to generate or update a standard `README.md`. |
| `menu_ajuda.sh` | Displays versioning best practices, directory conventions, and commit flow. |

### 🔁 Typical Workflow

1. **Project Creation**  
   - Use `iniciar_projeto.sh` to automatically create the base structure:
     ```bash
     codes/
       └── my_project/
           ├── src/
           ├── data/
           ├── results/
           ├── docs/
           ├── .gitignore
           ├── LICENSE
           └── README.md
     ```
   - The script runs `git init` and performs the first commit (`feat: scientific project initialized via AESC`).

2. **Editing and Documentation**  
   - Edit code in `src/`, place input data in `data/`, and store outputs in `results/`.
   - Use `gerar_readme.sh` to build or update a clear, reproducible `README.md`.

3. **Versioning and Synchronization**  
   - Add and commit changes normally:
     ```bash
     git add -A
     git commit -m "commit message"
     ```
   - To sync with GitHub:
     ```bash
     git remote add origin https://github.com/user/repo.git
     git branch -M main
     git push -u origin main
     ```

4. **Cloning Existing Projects**  
   - Use `clonar_repo.sh` to download a public GitHub repository into `codes/`.  
   - The script checks dependencies and confirms the destination before cloning.

### ⚙️ Directory Layout

```
aesc/
├── codes/                        → Scientific repositories and projects
│    ├── my_project/
│    │    ├── src/
│    │    ├── data/
│    │    ├── results/
│    │    └── docs/
├── simulations/                  → Simulations from other environments
└── etc/env.sh                    → Global environment variables
```

### 🧩 Integration and Portability

- All paths are relative to `$AESC_ROOT` and configured in `env.sh`.  
- Requires Git to be installed (`git --version`).  
- Works fully **offline**; connection to GitHub is optional.  
- Standard templates for `.gitignore`, `LICENSE`, and `README.md` ensure uniformity across projects.

### 💡 Notes

- License selection is interactive (`MIT`, `BSD-3`, `Apache-2.0`).  
- The README wizard includes project title, context, dependencies, and author info.  
- Designed to make Git workflow simple and reproducible for research projects.

---

## 🤝 Créditos / Credits

Desenvolvido por **Prof. Rafael Gabler Gontijo**  
L2C - Soluções em Computação Científica  
