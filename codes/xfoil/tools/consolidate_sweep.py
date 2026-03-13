#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
import pandas as pd


def is_float(s: str) -> bool:
    try:
        float(s)
        return True
    except Exception:
        return False


def read_xfoil_polar(path: Path) -> pd.DataFrame:
    rows = []
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if not parts:
                continue
            if not is_float(parts[0]):
                continue

            nums = []
            for p in parts:
                if is_float(p):
                    nums.append(float(p))

            if len(nums) >= 5:
                while len(nums) < 7:
                    nums.append(float("nan"))
                rows.append(nums[:7])

    if not rows:
        raise ValueError(f"Nenhuma linha de dados encontrada em {path}")

    return pd.DataFrame(
        rows,
        columns=["alpha", "CL", "CD", "CDp", "CM", "Top_Xtr", "Bot_Xtr"]
    )


def parse_case_name(case_name: str):
    """
    Ex: NACA2412_Re100000_Mach0p1
    """
    m = re.match(r"NACA(?P<airfoil>\d+)_Re(?P<re>[^_]+)_Mach(?P<mach>.+)", case_name)
    if not m:
        return None

    airfoil = m.group("airfoil")
    re_val = m.group("re").replace("p", ".").replace("m", "-")
    mach_val = m.group("mach").replace("p", ".").replace("m", "-")

    try:
        re_val = float(re_val)
    except Exception:
        pass

    try:
        mach_val = float(mach_val)
    except Exception:
        pass

    return airfoil, re_val, mach_val


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--campaign", required=True)
    args = parser.parse_args()

    campaign = Path(args.campaign)
    if not campaign.is_dir():
        raise FileNotFoundError(f"Campanha não encontrada: {campaign}")

    all_frames = []

    for case_dir in sorted(campaign.iterdir()):
        if not case_dir.is_dir():
            continue

        polar_file = case_dir / "polar.dat"
        if not polar_file.exists():
            continue

        try:
            df = read_xfoil_polar(polar_file)
        except Exception as e:
            print(f"[WARN] Pulando {case_dir.name}: {e}")
            continue

        parsed = parse_case_name(case_dir.name)
        if parsed is not None:
            airfoil, re_val, mach_val = parsed
        else:
            airfoil, re_val, mach_val = None, None, None

        df["case_name"] = case_dir.name
        df["airfoil"] = airfoil
        df["Re"] = re_val
        df["Mach"] = mach_val

        all_frames.append(df)

    if not all_frames:
        raise RuntimeError("Nenhuma polar válida encontrada na campanha.")

    df_all = pd.concat(all_frames, ignore_index=True)

    out_csv = campaign / "campaign_polars.csv"
    df_all.to_csv(out_csv, index=False)

    print(f"==> CSV consolidado gerado: {out_csv}")


if __name__ == "__main__":
    main()
