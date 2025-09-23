#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# IMPORTANDO AS BIBLIOTECAS NECESSÁRIAS
import os
from pathlib import Path
from datetime import datetime
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")  # backend não-interativo (salva figuras)
import matplotlib.pyplot as plt

# === Caminhos base ===
SCRIPT_DIR = Path(__file__).resolve().parent

# Se o executor do AESC definiu AESC_OUTDIR, usamos essa pasta.
_env_out = os.environ.get("AESC_OUTDIR", "").strip()
if _env_out:
    OUT_DIR = Path(_env_out).resolve()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
else:
    # Fallback: criar uma pasta local com timestamp, se rodar manualmente
    OUT_DIR = (SCRIPT_DIR / f"out_MLRM-MHT_{datetime.now().strftime('%Y%m%d-%H%M%S')}").resolve()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

def read_local_csv(filename, **kwargs):
    path = (SCRIPT_DIR / filename).resolve()
    if not path.is_file():
        raise FileNotFoundError(f"Arquivo CSV não encontrado: {path}")
    return pd.read_csv(path, **kwargs)

# ===== LENDO OS DADOS GERADOS (AGORA RELATIVOS) =====
dados = read_local_csv(
    "generated_database.csv",
    names=["volume_fraction", "field_intensity", "field_frequency",
           "particle_radius", "tumour_temperature", "time"],
    sep=" "
)

# ===== SPLIT E NORMALIZAÇÃO =====
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

X = dados.drop(["tumour_temperature", "time"], axis=1)
y  = dados["tumour_temperature"]
y2 = dados["time"]

X_train, X_test, y_train, y_test   = train_test_split(X, y,  test_size=0.3, random_state=125)
X_train2, X_test2, y_train2, y_test2 = train_test_split(X, y2, test_size=0.3, random_state=126)

scaler = StandardScaler()
train_scaled  = scaler.fit_transform(X_train)
test_scaled   = scaler.transform(X_test)
train_scaled2 = scaler.fit_transform(X_train2)
test_scaled2  = scaler.transform(X_test2)

# ===== MODELOS =====
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.neural_network import MLPRegressor

tree_model = DecisionTreeRegressor().fit(train_scaled,  y_train)
tree_model2 = DecisionTreeRegressor().fit(train_scaled2, y_train2)

rf_model = RandomForestRegressor().fit(train_scaled,  y_train)
rf_model2 = RandomForestRegressor().fit(train_scaled2, y_train2)

nn_model = MLPRegressor(hidden_layer_sizes=(500,), max_iter=1000,
                        alpha=1e-4, solver='sgd', verbose=False).fit(train_scaled,  y_train)
nn_model2 = MLPRegressor(hidden_layer_sizes=(500,), max_iter=1000,
                         alpha=1e-4, solver='sgd', verbose=False).fit(train_scaled2, y_train2)

lr_model = LinearRegression().fit(train_scaled,  y_train)
lr_model2 = LinearRegression().fit(train_scaled2, y_train2)

kn_model = KNeighborsRegressor().fit(train_scaled,  y_train)
kn_model2 = KNeighborsRegressor().fit(train_scaled2, y_train2)

# ===== MÉTRICAS =====
from sklearn.metrics import mean_absolute_error

tree_test_mae = mean_absolute_error(y_test,  tree_model.predict(test_scaled))
rf_test_mae   = mean_absolute_error(y_test,  rf_model.predict(test_scaled))
lr_test_mae   = mean_absolute_error(y_test,  lr_model.predict(test_scaled))
kn_test_mae   = mean_absolute_error(y_test,  kn_model.predict(test_scaled))
nn_test_mae   = mean_absolute_error(y_test,  nn_model.predict(test_scaled))

tree_test_mae2 = mean_absolute_error(y_test2, tree_model2.predict(test_scaled2))
rf_test_mae2   = mean_absolute_error(y_test2, rf_model2.predict(test_scaled2))
lr_test_mae2   = mean_absolute_error(y_test2, lr_model2.predict(test_scaled2))
kn_test_mae2   = mean_absolute_error(y_test2, kn_model2.predict(test_scaled2))
nn_test_mae2   = mean_absolute_error(y_test2, nn_model2.predict(test_scaled2))

# ===== LOG DE MÉTRICAS =====
with open(OUT_DIR / "metricas.txt", "w") as f:
    print("Algorithm errors for temperature prediction", file=f)
    print("Linear regression mean absolute error =", lr_test_mae, file=f)
    print("Decision Tree test mean absolute error =", tree_test_mae, file=f)
    print("Random Forest test mean absolute error =", rf_test_mae, file=f)
    print("K Nearest Neighbors test mean absolute error =", kn_test_mae, file=f)
    print("Neural Networks test mean absolute error =", nn_test_mae, file=f)
    print("", file=f)
    print("Algorithm errors for development time prediction", file=f)
    print("Linear regression mean absolute error =", lr_test_mae2, file=f)
    print("Decision Tree test mean absolute error =", tree_test_mae2, file=f)
    print("Random Forest test mean absolute error =", rf_test_mae2, file=f)
    print("K Nearest Neighbors test mean absolute error =", kn_test_mae2, file=f)
    print("Neural Networks test mean absolute error =", nn_test_mae2, file=f)

# ===== PREVISÕES =====
previsaolr   = lr_model.predict(test_scaled)
previsaorf   = rf_model.predict(test_scaled)
previsaodt   = tree_model.predict(test_scaled)
previsaokn   = kn_model.predict(test_scaled)
previsaonn   = nn_model.predict(test_scaled)

previsaolr2  = lr_model2.predict(test_scaled2)
previsaorf2  = rf_model2.predict(test_scaled2)
previsaodt2  = tree_model2.predict(test_scaled2)
previsaokn2  = kn_model2.predict(test_scaled2)
previsaonn2  = nn_model2.predict(test_scaled2)

alvo  = np.array(y_test)[:]
alvo2 = np.array(y_test2)[:]

# ===== FIGURAS: y_pred vs y_true (NN) =====
plt.figure()
plt.scatter(previsaonn, alvo, s=10, c='blue')
lims = [min(alvo.min(), previsaonn.min()), max(alvo.max(), previsaonn.max())]
plt.plot(lims, lims)
plt.xlabel("Previsto (NN)"); plt.ylabel("Verdadeiro")
plt.title("Temperatura - NN")
plt.grid(True)
plt.tight_layout()
plt.savefig(OUT_DIR / "nn_temp_ytrue_vs_ypred.png", dpi=200)
plt.close()

plt.figure()
plt.scatter(previsaonn2, alvo2, s=10, c='blue')
lims2 = [min(alvo2.min(), previsaonn2.min()), max(alvo2.max(), previsaonn2.max())]
plt.plot(lims2, lims2)
plt.xlabel("Previsto (NN)"); plt.ylabel("Verdadeiro")
plt.title("Tempo - NN")
plt.grid(True)
plt.tight_layout()
plt.savefig(OUT_DIR / "nn_time_ytrue_vs_ypred.png", dpi=200)
plt.close()

# ===== VARREDURAS & CURVAS =====
phi_min, phi_max = 0.03, 0.10
H_min, H_max     = 2000, 10000
w_min, w_max     = 100000, 350000
a_min, a_max     = 5e-9, 1e-8

range_phi = np.linspace(phi_min, phi_max, 1000)
range_H   = np.linspace(H_min,   H_max,   1000)
range_w   = np.linspace(w_min,   w_max,   1000)
range_a   = np.linspace(a_min,   a_max,   1000)

phi_ref, H_ref, w_ref, a_ref = 0.033, 3000, 184000, 5e-9

varredura_phi = pd.DataFrame({"volume_fraction": range_phi, "field_intensity": H_ref, "field_frequency": w_ref, "particle_radius": a_ref})
varredura_H   = pd.DataFrame({"volume_fraction": phi_ref, "field_intensity": range_H, "field_frequency": w_ref, "particle_radius": a_ref})
varredura_w   = pd.DataFrame({"volume_fraction": phi_ref, "field_intensity": H_ref, "field_frequency": range_w, "particle_radius": a_ref})
varredura_a   = pd.DataFrame({"volume_fraction": phi_ref, "field_intensity": H_ref, "field_frequency": w_ref, "particle_radius": range_a})

phi_scaled = scaler.transform(varredura_phi)
H_scaled   = scaler.transform(varredura_H)
w_scaled   = scaler.transform(varredura_w)
a_scaled   = scaler.transform(varredura_a)

previsaonn_varredura_phi  = nn_model.predict(phi_scaled)
previsaonn2_varredura_phi = nn_model2.predict(phi_scaled)

previsaonn_varredura_H  = nn_model.predict(H_scaled)
previsaonn2_varredura_H = nn_model2.predict(H_scaled)

previsaonn_varredura_w  = nn_model.predict(w_scaled)
previsaonn2_varredura_w = nn_model2.predict(w_scaled)

previsaonn_varredura_a  = nn_model.predict(a_scaled)
previsaonn2_varredura_a = nn_model2.predict(a_scaled)

# LENDO DADOS DAS VARREDURAS (AGORA RELATIVOS à pasta do script)
dados_phi = read_local_csv("var_phi_ref.csv",
    names=["volume_fraction","field_intensity","field_frequency","particle_radius","tumour_temperature","time"],
    sep=" ")
dados_H = read_local_csv("var_H_ref.csv",
    names=["volume_fraction","field_intensity","field_frequency","particle_radius","tumour_temperature","time"],
    sep=" ")
dados_w = read_local_csv("var_w_ref.csv",
    names=["volume_fraction","field_intensity","field_frequency","particle_radius","tumour_temperature","time"],
    sep=" ")
dados_a = read_local_csv("var_a_ref.csv",
    names=["volume_fraction","field_intensity","field_frequency","particle_radius","tumour_temperature","time"],
    sep=" ")

X_phi, T_phi, time_phi = dados_phi["volume_fraction"], dados_phi["tumour_temperature"], dados_phi["time"]
X_H,   T_H,   time_H   = dados_H["field_intensity"],   dados_H["tumour_temperature"],   dados_H["time"]
X_w,   T_w,   time_w   = dados_w["field_frequency"],   dados_w["tumour_temperature"],   dados_w["time"]
X_a,   T_a,   time_a   = dados_a["particle_radius"],   dados_a["tumour_temperature"],   dados_a["time"]

# GRÁFICOS – Temperatura
fig, axis = plt.subplots(2,2, figsize=(10,8))
axis[0,0].plot(range_phi, previsaonn_varredura_phi,  label="NN")
axis[0,0].scatter(X_phi, T_phi, s=10, c='black', label="Ref")
axis[0,0].set_ylim(35,60); axis[0,0].set_title("Volume fraction"); axis[0,0].grid(True)

axis[0,1].plot(range_H, previsaonn_varredura_H,  label="NN")
axis[0,1].scatter(X_H, T_H, s=10, c='black', label="Ref")
axis[0,1].set_ylim(35,80); axis[0,1].set_title("Field intensity"); axis[0,1].grid(True)

axis[1,0].plot(range_w, previsaonn_varredura_w,  label="NN")
axis[1,0].scatter(X_w, T_w, s=10, c='black', label="Ref")
axis[1,0].set_ylim(35,60); axis[1,0].set_title("Field frequency"); axis[1,0].grid(True)

axis[1,1].plot(range_a, previsaonn_varredura_a,  label="NN")
axis[1,1].scatter(X_a, T_a, s=10, c='black', label="Ref")
axis[1,1].set_ylim(35,65); axis[1,1].set_title("Particle radius"); axis[1,1].grid(True)

plt.tight_layout()
plt.savefig(OUT_DIR / "curvas_temperatura.png", dpi=200)
plt.close()

# GRÁFICOS – Tempo
fig, axis = plt.subplots(2,2, figsize=(10,8))
axis[0,0].plot(range_phi, previsaonn2_varredura_phi,  label="NN")
axis[0,0].scatter(X_phi, time_phi, s=10, c='black', label="Ref")
axis[0,0].set_title("Volume fraction"); axis[0,0].grid(True)

axis[0,1].plot(range_H, previsaonn2_varredura_H,  label="NN")
axis[0,1].scatter(X_H, time_H, s=10, c='black', label="Ref")
axis[0,1].set_title("Field intensity"); axis[0,1].grid(True)

axis[1,0].plot(range_w, previsaonn2_varredura_w,  label="NN")
axis[1,0].scatter(X_w, time_w, s=10, c='black', label="Ref")
axis[1,0].set_title("Field frequency"); axis[1,0].grid(True)

axis[1,1].plot(range_a, previsaonn2_varredura_a,  label="NN")
axis[1,1].scatter(X_a, time_a, s=10, c='black', label="Ref")
axis[1,1].set_title("Particle radius"); axis[1,1].grid(True)

plt.tight_layout()
plt.savefig(OUT_DIR / "curvas_tempo.png", dpi=200)
plt.close()

print(f"✅ Resultados salvos em: {OUT_DIR}")
