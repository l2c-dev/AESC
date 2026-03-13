#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def _is_float(s: str) -> bool:
    try:
        float(s)
        return True
    except Exception:
        return False


def read_xfoil_polar(path: str) -> pd.DataFrame:
    """
    Lê arquivo polar do XFOIL (texto com cabeçalho variado) e retorna
    DataFrame com colunas: alpha, CL, CD, CDp, CM, Top_Xtr, Bot_Xtr
    """
    rows = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if not parts:
                continue
            if not _is_float(parts[0]):
                continue

            nums = []
            for p in parts:
                if _is_float(p):
                    nums.append(float(p))

            if len(nums) >= 5:
                while len(nums) < 7:
                    nums.append(float("nan"))
                rows.append(nums[:7])

    if not rows:
        raise ValueError(f"Nenhuma linha de dados numéricos encontrada em {path}")

    return pd.DataFrame(rows, columns=["alpha", "CL", "CD", "CDp", "CM", "Top_Xtr", "Bot_Xtr"])


def read_cp_file_raw(path: Path) -> pd.DataFrame:
    """
    Lê um arquivo CPWR do XFOIL (ASCII) e retorna DataFrame com colunas x, cp
    preservando a ORDEM do arquivo (importante para separar topo/fundo).
    """
    xs, cps = [], []
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            if _is_float(parts[0]) and _is_float(parts[1]):
                xs.append(float(parts[0]))
                cps.append(float(parts[1]))

    if not xs:
        raise ValueError(f"Arquivo Cp parece vazio/inesperado: {path}")

    df = pd.DataFrame({"x": xs, "cp": cps})

    # sanidade: mantém só faixa típica (evita lixo)
    df = df[(df["x"] > -0.05) & (df["x"] < 1.5)]
    df = df[(df["cp"] > -200.0) & (df["cp"] < 50.0)]

    # remove NaNs se houver
    df = df.dropna(subset=["x", "cp"]).reset_index(drop=True)
    return df


def split_top_bottom(df_raw: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """
    Separa topo e fundo usando o ponto de LE ~ mínimo x.
    Assume que o arquivo percorre o contorno: TE -> ... -> LE -> ... -> TE.
    """
    if df_raw.empty:
        raise ValueError("df_raw vazio ao separar topo/fundo")

    i_le = int(df_raw["x"].idxmin())

    # duas metades no sentido do contorno
    top = df_raw.iloc[: i_le + 1].copy()
    bot = df_raw.iloc[i_le: ].copy()

    # ordena por x crescente para plot / interpolação
    top = top.sort_values("x").reset_index(drop=True)
    bot = bot.sort_values("x").reset_index(drop=True)

    # remove duplicatas de x (às vezes há repetição no LE/TE)
    top = top.drop_duplicates(subset=["x"], keep="first")
    bot = bot.drop_duplicates(subset=["x"], keep="first")

    return top, bot


def alpha_from_filename(p: Path) -> float | None:
    """
    Extrai alpha do filename.

    Aceita, por exemplo:
      - cp_alpha_+04.00.dat
      - cp_alpha_-04.00.dat
      - cp_alpha_p10p0.dat
      - cp_alpha_m0p5.dat
      - cp_alpha_p14,0.dat
      - cp_alpha_m3.5.dat
    """
    name = p.stem  # sem extensão

    # 1) padrão com sinal explícito: +04.00 ou -04.00
    m = re.search(r"cp_alpha_([+\-]\d+(?:\.\d+)?)$", name)
    if m:
        try:
            return float(m.group(1))
        except Exception:
            return None

    # 2) padrão com p/m como sinal e p/./, como separador decimal
    #    exemplos: p10p0, m0p5, p14,0, m3.5
    m = re.search(r"cp_alpha_([pm])(\d+(?:[p.,]\d+)?)$", name)
    if m:
        sign = 1.0 if m.group(1) == "p" else -1.0
        num = m.group(2).replace("p", ".").replace(",", ".")
        try:
            return sign * float(num)
        except Exception:
            return None

    return None


def alpha_safe_tag(a: float) -> str:
    """
    Gera tag compatível com os nomes atuais:
      +4.0  -> p4p0
      -0.5  -> m0p5
      +10.5 -> p10p5
    """
    if a < 0:
        s = f"m{abs(a):.1f}"
    else:
        s = f"p{a:.1f}"
    return s.replace(".", "p")


def interp_to_grid(x: np.ndarray, y: np.ndarray, xg: np.ndarray) -> np.ndarray:
    """
    Interpola y(x) em xg. Fora do intervalo, retorna NaN.
    """
    if len(x) < 2:
        return np.full_like(xg, np.nan, dtype=float)

    # garante monotonicidade
    order = np.argsort(x)
    x = x[order]
    y = y[order]

    yg = np.interp(xg, x, y, left=np.nan, right=np.nan)
    # np.interp não coloca NaN automaticamente fora do range se left/right forem NaN?
    # coloca sim, desde que sejam float. então ok.
    return yg


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--polar", required=True)
    parser.add_argument("--cp_dir", required=True)
    parser.add_argument("--outdir", required=True)

    # heatmap grid
    parser.add_argument("--nx", type=int, default=400, help="Número de pontos na malha x para heatmap")
    parser.add_argument("--xmin", type=float, default=0.0)
    parser.add_argument("--xmax", type=float, default=1.0)

    args = parser.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    polar = read_xfoil_polar(args.polar)

    # --- Polar: CL vs alpha
    plt.figure()
    plt.plot(polar["alpha"], polar["CL"], "-o")
    plt.xlabel("alpha (deg)")
    plt.ylabel("CL")
    plt.title("Polar: CL vs alpha")
    plt.grid(True)
    plt.savefig(outdir / "polar_CL_vs_alpha.png", dpi=150)
    plt.close()

    # --- Polar: CD vs CL
    plt.figure()
    plt.plot(polar["CL"], polar["CD"], "-o")
    plt.xlabel("CL")
    plt.ylabel("CD")
    plt.title("Polar: CD vs CL")
    plt.grid(True)
    plt.savefig(outdir / "polar_CD_vs_CL.png", dpi=150)
    plt.close()

    # --- Cp(x) por alpha (top/bot) + salvar CSVs
    cp_dir = Path(args.cp_dir)
    cp_files = sorted(cp_dir.glob("cp_alpha_*.dat"))
    if not cp_files:
        raise FileNotFoundError(f"Nenhum arquivo cp_alpha_*.dat encontrado em {cp_dir}")

    # pastas de saída
    out_csv = outdir / "cp_csv"
    out_ind = outdir / "cp_individual"
    out_csv.mkdir(parents=True, exist_ok=True)
    out_ind.mkdir(parents=True, exist_ok=True)

    # coletor p/ heatmap
    alphas = []
    top_rows = []
    bot_rows = []

    xg = np.linspace(args.xmin, args.xmax, args.nx)

    for p in cp_files:
        a = alpha_from_filename(p)
        if a is None:
            print(f"[WARN] Nome fora do padrão, pulando: {p.name}")
            continue

        try:
            df_raw = read_cp_file_raw(p)
            top, bot = split_top_bottom(df_raw)
        except Exception as e:
            print(f"[WARN] Pulando {p.name}: {e}")
            continue

        tag = alpha_safe_tag(a)

        # salva CSVs topo/fundo
        top.to_csv(out_csv / f"cp_alpha_{tag}_top.csv", index=False)
        bot.to_csv(out_csv / f"cp_alpha_{tag}_bot.csv", index=False)

        # figura individual por alpha
        plt.figure()
        plt.plot(top["x"], top["cp"], label="top")
        plt.plot(bot["x"], bot["cp"], label="bottom")
        plt.xlabel("x/c")
        plt.ylabel("Cp")
        plt.title(f"Cp(x) - alpha = {a:.2f} deg")
        plt.gca().invert_yaxis()
        plt.grid(True)
        plt.legend()
        plt.savefig(out_ind / f"Cp_vs_x_alpha_{tag}.png", dpi=150)
        plt.close()

        # prepara heatmap (interpola topo/fundo na mesma malha)
        top_i = interp_to_grid(top["x"].to_numpy(), top["cp"].to_numpy(), xg)
        bot_i = interp_to_grid(bot["x"].to_numpy(), bot["cp"].to_numpy(), xg)

        alphas.append(a)
        top_rows.append(top_i)
        bot_rows.append(bot_i)

    if not alphas:
        raise RuntimeError("Nenhum Cp válido foi lido/convertido para gerar plots/heatmap.")

    # ordena por alpha crescente
    order = np.argsort(alphas)
    alphas = np.array(alphas)[order]
    top_mat = np.vstack(top_rows)[order, :]
    bot_mat = np.vstack(bot_rows)[order, :]

    # --- Figura “all” (sem legenda gigante): escolhe poucas curvas para referência
    plt.figure()
    n_show = min(8, len(alphas))
    idxs = np.linspace(0, len(alphas) - 1, n_show, dtype=int)

    for i in idxs:
        a = alphas[i]
        tag = alpha_safe_tag(float(a))
        # lê os csv já salvos (garante consistência)
        top = pd.read_csv(out_csv / f"cp_alpha_{tag}_top.csv")
        bot = pd.read_csv(out_csv / f"cp_alpha_{tag}_bot.csv")
        plt.plot(top["x"], top["cp"], label=f"top {a:.1f}°")
        plt.plot(bot["x"], bot["cp"], linestyle="--", label=f"bot {a:.1f}°")

    plt.xlabel("x/c")
    plt.ylabel("Cp")
    plt.title("Cp(x) - amostra de alphas (top sólido, bottom tracejado)")
    plt.gca().invert_yaxis()
    plt.grid(True)
    plt.legend(fontsize=8, ncol=2)
    plt.savefig(outdir / "Cp_vs_x_sample.png", dpi=150)
    plt.close()

    # --- Heatmap topo
    plt.figure()
    plt.imshow(
        top_mat,
        aspect="auto",
        origin="lower",
        extent=[xg.min(), xg.max(), alphas.min(), alphas.max()],
        interpolation="nearest",
    )
    plt.xlabel("x/c")
    plt.ylabel("alpha (deg)")
    plt.title("Heatmap Cp(x, alpha) - TOP")
    plt.colorbar(label="Cp")
    plt.gca().invert_yaxis()  # Cp costuma ser plotado com eixo invertido; aqui é mapa: opcional
    plt.savefig(outdir / "Cp_heatmap_top.png", dpi=150)
    plt.close()

    # --- Heatmap fundo
    plt.figure()
    plt.imshow(
        bot_mat,
        aspect="auto",
        origin="lower",
        extent=[xg.min(), xg.max(), alphas.min(), alphas.max()],
        interpolation="nearest",
    )
    plt.xlabel("x/c")
    plt.ylabel("alpha (deg)")
    plt.title("Heatmap Cp(x, alpha) - BOTTOM")
    plt.colorbar(label="Cp")
    plt.gca().invert_yaxis()
    plt.savefig(outdir / "Cp_heatmap_bottom.png", dpi=150)
    plt.close()

    # salva também as matrizes como CSV (útil pra análise)
    pd.DataFrame(top_mat, index=alphas, columns=xg).to_csv(outdir / "Cp_heatmap_top.csv")
    pd.DataFrame(bot_mat, index=alphas, columns=xg).to_csv(outdir / "Cp_heatmap_bottom.csv")

    print("==> Figuras/CSVs gerados em:", outdir)
    print("    - individuais:", out_ind)
    print("    - csv topo/fundo:", out_csv)
    print("    - heatmaps: Cp_heatmap_top.png / Cp_heatmap_bottom.png")


if __name__ == "__main__":
    main()
