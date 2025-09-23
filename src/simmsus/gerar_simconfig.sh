#!/bin/bash

# Caminhos relativos (portabilidade AESC)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/simmsus")"
GEN_DIR="$(readlink -f "$ROOT_DIR/../codigos/simmsus")"
GEN="$GEN_DIR/simconfig_generator.sh"   # gerador na raiz do código Simmsus

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║      Ambiente de execução – Simmsus 🧲 | Geração e organização do config     ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificações necessárias
if [[ ! -d "$SIM_DIR" ]]; then
  echo "❌ Diretório de simulações não encontrado: $SIM_DIR"
  echo "   Verifique a instalação do AESC (simulacoes/simmsus)."
  echo ""
  read -p "Pressione ENTER para retornar ao menu Simmsus..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1
fi

if [[ ! -f "$GEN" ]]; then
  echo "❌ Gerador não encontrado: $GEN"
  echo "   Coloque 'simconfig_generator.sh' na raiz de 'codigos/simmsus/'."
  echo ""
  read -p "Pressione ENTER para retornar ao menu Simmsus..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1
fi
chmod +x "$GEN" 2>/dev/null

# Diretório temporário de geração (apenas para o processo do gerador)
TS="$(date +'%Y%m%d-%H%M%S')"
TMP_DIR="$SIM_DIR/_tmp_gen_$TS"
mkdir -p "$TMP_DIR" || { echo "❌ Falha ao criar $TMP_DIR"; read -p "ENTER para voltar..."; bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1; }

# 1) Executa o gerador na pasta temporária (síncrono) e captura status real
echo "⚙️  Executando gerador interativo em: $TMP_DIR"
echo "    (saída registrada em generator.log)"
echo ""
(
  cd "$TMP_DIR" || exit 1
  bash "$GEN" |& tee generator.log
  GEN_STATUS=${PIPESTATUS[0]}
  exit $GEN_STATUS
)
GEN_STATUS=$?

# 2) Validação pós-geração: só prossegue se concluiu OK e o simconfig.dat existe
CONFIG="$TMP_DIR/simconfig.dat"
if [[ $GEN_STATUS -ne 0 ]]; then
  echo ""
  echo "❌ O gerador retornou código de erro ($GEN_STATUS)."
  echo "   Consulte o log: $TMP_DIR/generator.log"
  echo ""
  read -p "Pressione ENTER para retornar ao menu Simmsus..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1
fi

if [[ ! -s "$CONFIG" ]]; then
  echo ""
  echo "❌ Geração falhou: 'simconfig.dat' não foi criado ou está vazio."
  echo "   Verifique: $TMP_DIR/generator.log"
  echo ""
  read -p "Pressione ENTER para retornar ao menu Simmsus..."
  bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1
fi

# --------- Parsing do simconfig.dat para montar o nome da pasta ---------
#get_bool(){ awk -F':' -v k="$1" 'index($0,k)==1{gsub(/[[:space:]]/,"",$2); print toupper($2)}' "$CONFIG" | head -n1; }
#get_val(){  awk -F':' -v k="$1" 'index($0,k)==1{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2}' "$CONFIG" | head -n1; }

get_bool(){  # retorna TRUE/FALSE
  awk -F':' -v k="$1" '$0 ~ "^[[:space:]]*"k { gsub(/[[:space:]]/,"",$2); print toupper($2); exit }' "$CONFIG"
}

get_val(){   # retorna string do valor
  awk -F':' -v k="$1" '$0 ~ "^[[:space:]]*"k { gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2; exit }' "$CONFIG"
}


APPLY_FIELD="$(get_bool 'APPLY AN EXTERNAL MAGNETIC FIELD')"
OSCIL="$(get_bool 'OSCILLATORY FIELD')"
ROT="$(get_bool 'ROTATING FIELD')"
DUFF="$(get_bool 'NON-LINEAR DUFFING FIELD EXCITATION')"
F2X="$(get_bool 'DOUBLE FREQUENCY FIELD EXCITATION')"
BROWN="$(get_bool 'BROWNIAN MOTION')"
SHEAR_ON="$(get_bool 'TURN ON SHEAR RATE')"

NPART_RAW="$(get_val 'NUMBER OF PARTICLES')"
VF_RAW="$(get_val 'VOLUME FRACTION OF PARTICLES')"

# Normalizações
NPART="$(echo "$NPART_RAW" | sed 's/[^0-9]//g' | sed 's/^0*//')"; [[ -z "$NPART" ]] && NPART="0"
VF_INT="$(awk -v v="$VF_RAW" 'BEGIN{ if (v=="") {print 0; exit}; printf("%.0f", v*100); }')"
printf -v VF2D "%02d" "$VF_INT"

# Tags de nome
if [[ "$APPLY_FIELD" == "TRUE" ]]; then
  FIELD_TAG="field"
  if   [[ "$OSCIL" == "TRUE" ]]; then SUB="oscil"
  elif [[ "$ROT"   == "TRUE" ]]; then SUB="rot"
  elif [[ "$DUFF"  == "TRUE" ]]; then SUB="duff"
  elif [[ "$F2X"   == "TRUE" ]]; then SUB="2freq"
  else SUB="field"; fi
else
  FIELD_TAG="nofield"; SUB="nofield"
fi
[[ "$BROWN"    == "TRUE" ]] && BRTAG="brown"   || BRTAG="nobrown"
[[ "$SHEAR_ON" == "TRUE" ]] && SHTAG="shear"   || SHTAG="noshear"

# Montagem do nome final do caso
if [[ "$FIELD_TAG" == "field" ]]; then
  CASE_NAME="${FIELD_TAG}_${SUB}_${BRTAG}_${SHTAG}_n${NPART}_vf${VF2D}"
else
  CASE_NAME="${FIELD_TAG}_${BRTAG}_${SHTAG}_n${NPART}_vf${VF2D}"
fi

DEST_DIR="$SIM_DIR/$CASE_NAME"
[[ -e "$DEST_DIR" ]] && DEST_DIR="${DEST_DIR}_$TS"
mkdir -p "$DEST_DIR" || { echo "❌ Falha ao criar $DEST_DIR"; read -p 'ENTER para voltar...'; bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 1; }

# Move artefatos finais
mv "$CONFIG" "$DEST_DIR/simconfig.dat"
[[ -f "$TMP_DIR/generator.log" ]] && mv "$TMP_DIR/generator.log" "$DEST_DIR/"
rmdir "$TMP_DIR" 2>/dev/null || true

# Feedback final ao usuário
echo ""
echo "✅ 'simconfig.dat' gerado e organizado com sucesso."
echo "📁 Pasta do caso: $DEST_DIR"
echo ""
echo "📄 Prévia (últimas 20 linhas):"
echo "────────────────────────────────────────────"
tail -n 20 "$DEST_DIR/simconfig.dat"
echo "────────────────────────────────────────────"
echo ""
echo "💡 Agora execute via: Menu Simmsus → 'Executar simulação' e escolha:"
echo "   $CASE_NAME"
echo ""
read -p "Pressione ENTER para retornar ao menu Simmsus..."
bash "$SCRIPT_DIR/menu_simmsus.sh"; exit 0
