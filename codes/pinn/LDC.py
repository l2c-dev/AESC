#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys, json, time, argparse, platform, subprocess, shlex
from datetime import datetime

# Evita necessidade de display:
import matplotlib
matplotlib.use("Agg")

import numpy as np
import torch
import torch.nn as nn
import matplotlib.pyplot as plt
import pyvista as pv
import psutil

# ---------------------------
# Utilidades
# ---------------------------
def ensure_dir(path: str):
    os.makedirs(path, exist_ok=True)
    return path

def nowstamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def default_outdir(base_name: str) -> str:
    aesc_out = os.environ.get("AESC_OUTDIR", "").strip()
    if aesc_out:
        ensure_dir(aesc_out)
        return aesc_out
    return ensure_dir(base_name)

def write_json(path, obj):
    with open(path, "w") as f:
        json.dump(obj, f, indent=4, ensure_ascii=False)

def read_json(path):
    with open(path, "r") as f:
        return json.load(f)

def line_log(fp, msg: str):
    ts = nowstamp()
    fp.write(f"[{ts}] {msg}\n")
    fp.flush()

# ---------------------------
# PINN helpers
# ---------------------------
def build_net(layers, neurons, act, norm):
    modules = []
    for i in range(layers):
        modules.append(nn.Linear(2 if i == 0 else neurons, neurons))
        if norm:
            modules.append(nn.LayerNorm(neurons))
        modules.append(act())
    modules.append(nn.Linear(neurons, 3))
    return nn.Sequential(*modules)

def generate_points(N, tipo, device):
    if tipo == "lhs":
        pts = np.random.uniform(0, 1, (N, 2))
    else:
        pts = np.random.rand(N, 2)
    return torch.tensor(pts, dtype=torch.float32, device=device)

def generate_bc(N, device):
    lin = torch.linspace(0, 1, N, device=device).view(-1, 1)
    bottom = torch.cat([lin, torch.zeros_like(lin)], dim=1)
    top    = torch.cat([lin, torch.ones_like(lin)],  dim=1)
    left   = torch.cat([torch.zeros_like(lin), lin], dim=1)
    right  = torch.cat([torch.ones_like(lin), lin],  dim=1)

    x_bc = torch.cat([bottom, top, left, right], dim=0)
    u_bc = torch.cat([torch.zeros_like(lin), torch.ones_like(lin), torch.zeros_like(lin), torch.zeros_like(lin)], dim=0)
    v_bc = torch.zeros_like(u_bc)
    return x_bc, u_bc.view(-1,1), v_bc.view(-1,1)

def gradients(u, x, order=1):
    for _ in range(order):
        u = torch.autograd.grad(u, x, torch.ones_like(u), create_graph=True, retain_graph=True)[0]
    return u

def loss_function(model, x_f, x_bc, u_bc, v_bc, nu, w_f, w_u_top, w_u_rest, w_v):
    x_f.requires_grad = True
    out_f = model(x_f)
    u, v, p = out_f[:, 0:1], out_f[:, 1:2], out_f[:, 2:3]
    grads = lambda f: gradients(f, x_f)
    u_x, u_y = grads(u)[:, 0:1], grads(u)[:, 1:2]
    v_x, v_y = grads(v)[:, 0:1], grads(v)[:, 1:2]
    p_x, p_y = grads(p)[:, 0:1], grads(p)[:, 1:2]
    u_xx, u_yy = gradients(u_x, x_f)[:, 0:1], gradients(u_y, x_f)[:, 1:2]
    v_xx, v_yy = gradients(v_x, x_f)[:, 0:1], gradients(v_y, x_f)[:, 1:2]

    f_u = u*u_x + v*u_y + p_x - nu*(u_xx + u_yy)
    f_v = u*v_x + v*v_y + p_y - nu*(v_xx + v_yy)
    f_c = u_x + v_y
    loss_f = (f_u**2 + f_v**2 + f_c**2).mean()

    out_bc = model(x_bc)
    u_pred, v_pred = out_bc[:, 0:1], out_bc[:, 1:2]
    top_idx = (x_bc[:,1] == 1.0).squeeze()
    non_top_idx = ~top_idx
    all_idx = torch.arange(x_bc.shape[0], device=x_bc.device)

    mse = nn.MSELoss()
    loss_bc_u_top  = mse(u_pred[top_idx],   u_bc[top_idx])
    loss_bc_u_rest = mse(u_pred[non_top_idx], u_bc[non_top_idx])
    loss_bc_v      = mse(v_pred[all_idx],   v_bc[all_idx])

    loss_bc = w_u_top*loss_bc_u_top + w_u_rest*loss_bc_u_rest + w_v*loss_bc_v
    total   = w_f*loss_f + loss_bc
    return loss_f, loss_bc_u_top, loss_bc_u_rest, loss_bc_v, total

# ---------------------------
# Execução principal (treino)
# ---------------------------
def run_training(params_path: str, outdir: str):
    params = read_json(params_path)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    Re          = float(params["Re"])
    N_int       = int(params["N_int"])
    N_bc        = int(params["N_bc"])
    epochs      = int(params["epochs"])
    layers      = int(params["layers"])
    neurons     = int(params["neurons"])
    activation  = getattr(nn, params["activation"], nn.Tanh)
    use_lhs     = bool(params["LHS"])
    switch_opt  = bool(params["Troca_Opt_5000"])
    use_norm    = bool(params["Normalizacao"])
    w_f         = float(params["w_f"])
    w_u_top     = float(params["w_u_top"])
    w_u_rest    = float(params["w_u_rest"])
    w_v         = float(params["w_v"])

    nu = 1.0/Re

    # logs
    log_path = os.path.join(outdir, "log.treino")
    with open(log_path, "a", buffering=1) as flog:  # line buffered
        line_log(flog, f"Dispositivo: {'CUDA' if torch.cuda.is_available() else 'CPU'}")
        line_log(flog, f"Parâmetros: {json.dumps(params, ensure_ascii=False)}")

        # modelo e dados
        model = build_net(layers, neurons, activation, use_norm).to(device)
        x_f   = generate_points(N_int, "lhs" if use_lhs else "uniforme", device=device)
        x_bc, u_bc, v_bc = generate_bc(N_bc, device=device)

        optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)

        # arquivo .dat
        dat_path = os.path.join(outdir, "parametros_numericos.dat")
        with open(dat_path, "w") as fdat:
            fdat.write("#epoch loss_f loss_bc_u_top loss_bc_u_rest loss_bc_v u_avg u_std v_avg v_std\n")

            t0 = time.time()
            for epoch in range(epochs):
                model.train()
                loss_f, l_u_top, l_u_rest, l_v, loss_total = loss_function(
                    model, x_f, x_bc, u_bc, v_bc, nu, w_f, w_u_top, w_u_rest, w_v
                )
                optimizer.zero_grad()
                loss_total.backward()
                optimizer.step()

                # estatística na tampa
                x_sup = torch.linspace(0, 1, N_bc, device=device).view(-1, 1)
                y_sup = torch.ones_like(x_sup)
                pts   = torch.cat([x_sup, y_sup], dim=1)
                with torch.no_grad():
                    u_pred = model(pts)[:, 0].detach().cpu().numpy()
                    v_pred = model(pts)[:, 1].detach().cpu().numpy()
                    u_avg, u_std = float(u_pred.mean()), float(u_pred.std())
                    v_avg, v_std = float(v_pred.mean()), float(v_pred.std())

                # log linha .dat
                fdat.write(f"{epoch} {loss_f.item():.4e} {l_u_top.item():.4e} {l_u_rest.item():.4e} {l_v.item():.4e} {u_avg:.4e} {u_std:.4e} {v_avg:.4e} {v_std:.4e}\n")
                if epoch % 50 == 0:
                    line_log(flog, f"Época {epoch:05d} | loss_f={loss_f.item():.4e} "
                                   f"| loss_bc={(l_u_top+l_u_rest+l_v).item():.4e} "
                                   f"| total={loss_total.item():.4e} | ⟨u⟩_tampa={u_avg:.4f}")

                # troca de otimizador aos 5000
                if switch_opt and epoch == 5000:
                    optimizer = torch.optim.LBFGS(model.parameters(), lr=0.5, max_iter=500, history_size=50, line_search_fn="strong_wolfe")
                    line_log(flog, "Otimizador trocado para LBFGS (época 5000).")

            t1 = time.time()
            line_log(flog, f"Treino concluído em {t1 - t0:.2f} s")

        # pós-processamento
        # gráficos de perdas
        try:
            data = np.loadtxt(dat_path, comments="#")
            if data.ndim == 1:
                data = data[None, :]
            # colunas: epoch, loss_f, l_u_top, l_u_rest, l_v, u_avg, u_std, v_avg, v_std
            loss_names = ["loss_f", "loss_bc_u_top", "loss_bc_u_rest", "loss_bc_v"]
            for idx, name in enumerate(loss_names, start=1):
                plt.figure()
                plt.plot(data[:, idx])
                plt.yscale("log")
                plt.title(f"Evolução de {name}")
                plt.xlabel("Épocas")
                plt.tight_layout()
                plt.savefig(os.path.join(outdir, f"{name}.png"), dpi=200)
                plt.close()
        except Exception as e:
            line_log(flog, f"[WARN] Falha ao gerar gráficos de perda: {e}")

        # campos + VTK
        try:
            N = 100
            x = np.linspace(0, 1, N); y = np.linspace(0, 1, N)
            X, Y = np.meshgrid(x, y)
            XY = np.hstack([X.reshape(-1,1), Y.reshape(-1,1)])
            with torch.no_grad():
                out = model(torch.tensor(XY, dtype=torch.float32, device=device))
                u = out[:,0].detach().cpu().numpy().reshape(N,N)
                v = out[:,1].detach().cpu().numpy().reshape(N,N)
                p = out[:,2].detach().cpu().numpy().reshape(N,N)

            # PNGs
            for data_arr, name, cmap in zip([u, v, p], ["u", "v", "pressao"], ["viridis", "viridis", "coolwarm"]):
                plt.figure()
                plt.contourf(X, Y, data_arr, 50, cmap=cmap)
                plt.colorbar()
                plt.title(f"Campo de {name}")
                plt.axis("scaled")
                plt.tight_layout()
                plt.savefig(os.path.join(outdir, f"campo_{name}.png"), dpi=300)
                plt.close()

            # streamlines
            speed = np.sqrt(u**2 + v**2)
            plt.figure()
            plt.streamplot(X, Y, u, v, density=1.5, color=speed, cmap="plasma")
            plt.colorbar()
            plt.title("Linhas de Corrente")
            plt.axis("scaled")
            plt.tight_layout()
            plt.savefig(os.path.join(outdir, "streamlines.png"), dpi=300)
            plt.close()

            # VTK
            grid = pv.StructuredGrid()
            Xg, Yg, Zg = np.meshgrid(x, y, [0], indexing='ij')
            grid.points = np.c_[Xg.ravel(), Yg.ravel(), Zg.ravel()]
            grid.dimensions = [N, N, 1]
            velocity = np.c_[u.flatten(order='F'), v.flatten(order='F'), np.zeros_like(u.flatten())]
            grid.point_data["velocity"] = velocity
            grid.point_data["pressure"] = p.flatten(order='F')
            grid.save(os.path.join(outdir, "saida_pinn.vtk"))
        except Exception as e:
            line_log(flog, f"[WARN] Falha no pós-processamento/VTK: {e}")

        # infos do sistema
        try:
            tempo_total = time.time() - t0
            sistema_info = {
                "tempo_total_segundos": round(tempo_total, 2),
                "cpu": platform.processor(),
                "arquitetura": platform.machine(),
                "sistema": platform.system() + " " + platform.release(),
                "cpu_cores_fisicos": psutil.cpu_count(logical=False),
                "cpu_cores_logicos": psutil.cpu_count(logical=True),
                "memoria_total_GB": round(psutil.virtual_memory().total / 1e9, 2),
                "gpu_disponivel": torch.cuda.is_available(),
                "nome_gpu": torch.cuda.get_device_name(0) if torch.cuda.is_available() else "Nenhuma"
            }
            write_json(os.path.join(outdir, "info_execucao.json"), sistema_info)
            line_log(flog, f"Info de execução salva em info_execucao.json")
        except Exception as e:
            line_log(flog, f"[WARN] Falha ao registrar info de execução: {e}")

        line_log(flog, "✅ Execução concluída.")

# ---------------------------
# Coleta de parâmetros (prompts)
# ---------------------------
def prompt_params(args) -> (dict, str):
    # Atalhos para rodar sem perguntar (ex.: via menu AESC futuramente)
    activations = {"1":"Tanh", "2":"ReLU", "3":"Sigmoid", "4":"GELU"}

    def ask_float(msg): return float(input(msg).strip())
    def ask_int(msg):   return int(input(msg).strip())
    def ask_bool(msg):  return input(msg).strip().lower() == "s"

    if args.no_prompt:
        # tudo deve vir por flags
        if args.Re is None or args.N_int is None or args.N_bc is None or args.epochs is None or \
           args.layers is None or args.neurons is None or args.activation is None or \
           args.w_f is None or args.w_u_top is None or args.w_u_rest is None or args.w_v is None:
            print("❌ --no-prompt requer todos os parâmetros via flags.", file=sys.stderr)
            sys.exit(2)

        activation_name = activations.get(str(args.activation), "Tanh") if str(args.activation) in activations else args.activation
        params = {
            "Re": args.Re, "N_int": args.N_int, "N_bc": args.N_bc, "epochs": args.epochs,
            "layers": args.layers, "neurons": args.neurons,
            "activation": activation_name,
            "LHS": args.use_lhs, "Troca_Opt_5000": args.switch_opt, "Normalizacao": args.use_norm,
            "w_f": args.w_f, "w_u_top": args.w_u_top, "w_u_rest": args.w_u_rest, "w_v": args.w_v
        }
    else:
        Re       = ask_float("🔢 Digite o número de Reynolds: ")
        N_int    = ask_int  ("🔢 Nº de pontos internos: ")
        N_bc     = ask_int  ("🔢 Nº de pontos de contorno: ")
        epochs   = ask_int  ("🔁 Nº de épocas: ")
        layers   = ask_int  ("🏗️ Nº de camadas da rede: ")
        neurons  = ask_int  ("🧠 Nº de neurônios por camada: ")
        print("🎚️ Escolha a função de ativação:\n1️⃣  Tanh\n2️⃣  ReLU\n3️⃣  Sigmoid\n4️⃣  GELU")
        act_choice = input("Digite o número: ").strip()
        activation_name = activations.get(act_choice, "Tanh")

        use_lhs    = ask_bool("📐 Usar LHS? (s/n): ")
        switch_opt = ask_bool("🔁 Trocar otimizador após 5000 épocas? (s/n): ")
        use_norm   = ask_bool("🧪 Usar normalização em camadas? (s/n): ")

        w_f      = ask_float("⚖️  Peso para o termo do interior: ")
        w_u_top  = ask_float("⚖️  Peso para u na tampa superior: ")
        w_u_rest = ask_float("⚖️  Peso para u nas demais paredes: ")
        w_v      = ask_float("⚖️  Peso para v em todas as paredes: ")

        params = {
            "Re": Re, "N_int": N_int, "N_bc": N_bc, "epochs": epochs,
            "layers": layers, "neurons": neurons,
            "activation": activation_name,
            "LHS": use_lhs, "Troca_Opt_5000": switch_opt, "Normalizacao": use_norm,
            "w_f": w_f, "w_u_top": w_u_top, "w_u_rest": w_u_rest, "w_v": w_v
        }

    # nome do caso + outdir final
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_name = f"Re{int(params['Re'])}_N{int(params['N_int'])}_B{int(params['N_bc'])}_E{int(params['epochs'])}_{timestamp}"
    outdir = default_outdir(base_name)
    return params, outdir

# ---------------------------
# Main / Argparse
# ---------------------------
def parse_args():
    p = argparse.ArgumentParser(description="PINN cavidade cisalhante – modo launch & detach com logging.")
    sub = p.add_subparsers(dest="cmd")

    # modo padrão (coleta e lança em background)
    p.add_argument("--no-prompt", action="store_true", help="Não perguntar; usar somente parâmetros via flags.")
    p.add_argument("--detach", action="store_true", default=True, help="(padrão) Lança o treino em background e retorna o terminal.")
    # parâmetros (para --no-prompt)
    p.add_argument("--Re", type=float)
    p.add_argument("--N_int", type=int)
    p.add_argument("--N_bc", type=int)
    p.add_argument("--epochs", type=int)
    p.add_argument("--layers", type=int)
    p.add_argument("--neurons", type=int)
    p.add_argument("--activation", type=str, help="1/2/3/4 ou nome da classe (Tanh/ReLU/Sigmoid/GELU)")
    p.add_argument("--use-lhs", dest="use_lhs", action="store_true")
    p.add_argument("--no-use-lhs", dest="use_lhs", action="store_false"); p.set_defaults(use_lhs=None)
    p.add_argument("--switch-opt", dest="switch_opt", action="store_true")
    p.add_argument("--no-switch-opt", dest="switch_opt", action="store_false"); p.set_defaults(switch_opt=None)
    p.add_argument("--use-norm", dest="use_norm", action="store_true")
    p.add_argument("--no-use-norm", dest="use_norm", action="store_false"); p.set_defaults(use_norm=None)
    p.add_argument("--w-f", dest="w_f", type=float)
    p.add_argument("--w-u-top", dest="w_u_top", type=float)
    p.add_argument("--w-u-rest", dest="w_u_rest", type=float)
    p.add_argument("--w-v", dest="w_v", type=float)

    # modo interno (filho em background)
    r = sub.add_parser("_run_internal", help=argparse.SUPPRESS)
    r.add_argument("--params", required=True)
    r.add_argument("--outdir", required=True)

    return p.parse_args()

def main():
    args = parse_args()

    # Modo interno: executa o treino lendo JSON
    if args.cmd == "_run_internal":
        run_training(params_path=args.params, outdir=args.outdir)
        return

    # Coleta parâmetros e define pasta de saída
    params, outdir = prompt_params(args)
    ensure_dir(outdir)

    # Salva parametros.json
    params_path = os.path.join(outdir, "parametros.json")
    write_json(params_path, params)

    # Abre log e registra cabeçalho mínimo
    log_path = os.path.join(outdir, "log.treino")
    with open(log_path, "a", buffering=1) as flog:
        line_log(flog, "===== PINN – cavidade cisalhante =====")
        line_log(flog, f"Saída: {outdir}")
        line_log(flog, f"Parâmetros salvos em: parametros.json")

    # Lança em background (detach padrão)
    if args.detach:
        # Comando para reexecutar este script no modo interno
        py = shlex.quote(sys.executable)
        this = shlex.quote(os.path.abspath(sys.argv[0]))
        cmd = f"{py} {this} _run_internal --params {shlex.quote(params_path)} --outdir {shlex.quote(outdir)}"
        # Redireciona stdout/stderr para o log
        with open(log_path, "ab", buffering=0) as lf:
            proc = subprocess.Popen(
                cmd, shell=True,
                stdout=lf, stderr=lf, cwd=os.getcwd(), close_fds=True
            )
        print("")
        print("🚀 Execução iniciada em segundo plano.")
        print(f"   PID: {proc.pid}")
        print(f"   Pasta: {outdir}")
        print(f"   Log: {log_path}")
        print("")
        return
    else:
        # Execução síncrona (fica bloqueado)
        run_training(params_path=params_path, outdir=outdir)

if __name__ == "__main__":
    main()
