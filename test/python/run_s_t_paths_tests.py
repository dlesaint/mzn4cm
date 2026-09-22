"""Runs test/test_s_t_paths.mzn with the Chuffed solver over a batch of c-maps
(.dzn icmap files) and records solver statistics in a spreadsheet-friendly CSV file.

For each icmap file:
  - the influence type (enum or int/rational) is detected from the arc labels,
  - the matching i-type data file is selected (itype_opt_enum_signed.dzn or
    itype_opt_rational_min_max.dzn), and model/include/include_itype.mzn is
    toggled accordingly,
  - nb_paths and size_path are computed from the graph (exact count, falling
    back to a fast upper bound if the exact computation takes too long),
  - s_node and t_node are picked randomly among the graph's nodes,
  - minizinc is run with the Chuffed solver and full statistics enabled.

Usage:
    python run_s_t_paths_tests.py [-d data/icmap/kifanlo] [-o test/results/s_t_paths_results.csv]
"""
import argparse
import csv
import multiprocessing as mp
import os
import random
import re
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from preprocess_and_run import (
    parse_icmap_file,
    adj_matrix_to_nb_path,
    adj_matrix_to_nb_path_no_cycles,
    max_legth,
)

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MODEL_PATH = os.path.join(REPO_ROOT, "test", "test_s_t_paths.mzn")
INCLUDE_ITYPE_PATH = os.path.join(REPO_ROOT, "model", "include", "include_itype.mzn")
ITYPE_DATA = {
    "enum": os.path.join(REPO_ROOT, "data", "itype", "itype_opt_enum_signed.dzn"),
    "int": os.path.join(REPO_ROOT, "data", "itype", "itype_opt_rational_min_max.dzn"),
}

STAT_RE = re.compile(r"^%%%mzn-stat:\s*([\w]+)=(.*)$", re.MULTILINE)


# -------------------- influence type detection --------------------

def detect_influence_type(icmap_text):
    match = re.search(r'influence:\(iblock:\[([^\]]*)\]\)', icmap_text)
    if not match:
        raise ValueError("no arc influence block found to detect the influence type")
    first_component = match.group(1).split(",")[0].strip()
    return "int" if re.fullmatch(r"-?\d+", first_component) else "enum"


def count_arcs(icmap_text):
    return len(re.findall(r"\(arc:\(t:\d+, h:\d+\)", icmap_text))


# -------------------- include_itype.mzn toggling --------------------

def _toggle_include_line(line, marker, want_active):
    if marker not in line:
        return line
    ending = ""
    body = line
    for eol in ("\r\n", "\n"):
        if line.endswith(eol):
            ending, body = eol, line[: -len(eol)]
            break
    stripped = body.lstrip("% ")
    prefix = "  " if want_active else "% %"
    return prefix + stripped + ending


def set_include_itype(influence_type):
    with open(INCLUDE_ITYPE_PATH, "r", newline="", encoding="utf-8") as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        line = _toggle_include_line(line, 'itype/type/itype_enum_api.mzn"', influence_type == "enum")
        line = _toggle_include_line(line, 'itype/type/itype_rational_api.mzn"', influence_type == "int")
        new_lines.append(line)
    with open(INCLUDE_ITYPE_PATH, "w", newline="", encoding="utf-8") as f:
        f.writelines(new_lines)


# -------------------- nb_paths / size_path computation --------------------

def _exact_worker(adj_matrix, queue):
    try:
        nb_paths, _ = adj_matrix_to_nb_path_no_cycles(adj_matrix)
        size_path = max_legth(adj_matrix)
        queue.put(("ok", max(int(nb_paths), 1), max(int(size_path), 1)))
    except Exception as e:
        queue.put(("error", str(e), None))


def compute_path_bounds(adj_matrix, timeout_seconds):
    """Exact simple-path count/length, with a fast bound fallback if it takes too long."""
    node_count = max(int(adj_matrix.shape[0]), 1)
    queue = mp.Queue()
    proc = mp.Process(target=_exact_worker, args=(adj_matrix, queue), daemon=True)
    started = time.perf_counter()
    proc.start()
    proc.join(timeout_seconds)
    if proc.is_alive():
        proc.terminate()
        proc.join()
        nb_bound = max(int(adj_matrix_to_nb_path(adj_matrix)), 1)
        return nb_bound, node_count, "bound", time.perf_counter() - started

    elapsed = time.perf_counter() - started
    if not queue.empty():
        status, a, b = queue.get()
        if status == "ok":
            return a, b, "exact", elapsed

    nb_bound = max(int(adj_matrix_to_nb_path(adj_matrix)), 1)
    return nb_bound, node_count, "bound", elapsed


# -------------------- minizinc run + output parsing --------------------

def parse_status(stdout):
    if "=====UNSATISFIABLE=====" in stdout:
        return "UNSATISFIABLE"
    if "=====ERROR=====" in stdout:
        return "ERROR"
    if "=====UNKNOWN=====" in stdout:
        return "UNKNOWN"
    if "==========" in stdout:
        return "OPTIMAL"
    if "result_nb_paths" in stdout:
        return "SATISFIABLE_INCOMPLETE"
    return "NO_OUTPUT"


def parse_stats(stdout):
    stats = {}
    for key, value in STAT_RE.findall(stdout):
        stats[key] = value.strip().strip('"')
    return stats


def run_minizinc(icmap_path, itype_data_path, query_dzn_path, time_limit_ms):
    cmd = [
        "minizinc", MODEL_PATH,
        "-d", icmap_path,
        "-d", itype_data_path,
        "-d", query_dzn_path,
        "--solver", "Chuffed",
        "-s",
        "--time-limit", str(time_limit_ms),
    ]
    start = time.perf_counter()
    proc = subprocess.run(cmd, capture_output=True, text=True)
    wall_time = time.perf_counter() - start
    return cmd, proc, wall_time


# -------------------- main --------------------

def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-d", "--graphs-dir", default=os.path.join(REPO_ROOT, "data", "icmap", "kifanlo"),
                         help="Directory of .dzn icmap files to test (default: data/icmap/kifanlo)")
    parser.add_argument("-o", "--output", default=os.path.join(REPO_ROOT, "test", "results", "s_t_paths_results.csv"),
                         help="Path to the output CSV file")
    parser.add_argument("--raw-dir", default=os.path.join(REPO_ROOT, "test", "results", "raw"),
                         help="Directory where the full raw minizinc output of each run is saved")
    parser.add_argument("--time-limit-ms", type=int, default=60000, help="MiniZinc solver time limit in milliseconds")
    parser.add_argument("--path-calc-timeout", type=float, default=30.0,
                         help="Seconds allowed for the exact nb_paths/size_path computation before falling back to a bound")
    parser.add_argument("--seed", type=int, default=None, help="Random seed for s_node/t_node selection")
    parser.add_argument("--limit", type=int, default=None, help="Only process the first N files (for a quick smoke test)")
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    os.makedirs(args.raw_dir, exist_ok=True)

    files = sorted(f for f in os.listdir(args.graphs_dir) if f.endswith(".dzn"))
    if args.limit:
        files = files[: args.limit]

    with open(INCLUDE_ITYPE_PATH, "r", newline="", encoding="utf-8") as f:
        original_include_itype = f.read()

    rows = []
    try:
        for idx, filename in enumerate(files, start=1):
            icmap_path = os.path.join(args.graphs_dir, filename)
            print(f"[{idx}/{len(files)}] {filename}")

            with open(icmap_path, "r", encoding="utf-8") as f:
                icmap_text = f.read()

            row = {
                "file": filename,
                "path": icmap_path,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }

            try:
                influence_type = detect_influence_type(icmap_text)
                n_arcs = count_arcs(icmap_text)
                adj_matrix = parse_icmap_file(icmap_path)
                n_nodes = int(adj_matrix.shape[0])

                row.update({
                    "influence_type": influence_type,
                    "itype_data_file": os.path.basename(ITYPE_DATA[influence_type]),
                    "n_nodes": n_nodes,
                    "n_arcs": n_arcs,
                })

                set_include_itype(influence_type)

                nb_paths, size_path, path_calc_method, path_calc_seconds = compute_path_bounds(
                    adj_matrix, args.path_calc_timeout
                )
                row.update({
                    "nb_paths_param": nb_paths,
                    "size_path_param": size_path,
                    "path_calc_method": path_calc_method,
                    "path_calc_seconds": round(path_calc_seconds, 4),
                })

                s_node, t_node = random.sample(range(1, n_nodes + 1), 2)
                row.update({"s_node": s_node, "t_node": t_node})

                fd, query_dzn_path = tempfile.mkstemp(suffix=".dzn", prefix="s_t_paths_query_")
                try:
                    with os.fdopen(fd, "w", encoding="utf-8") as f:
                        f.write(f"s_node={s_node};\n")
                        f.write(f"t_node={t_node};\n")
                        f.write(f"nb_paths={nb_paths};\n")
                        f.write(f"size_path={size_path};\n")

                    cmd, proc, wall_time = run_minizinc(
                        icmap_path, ITYPE_DATA[influence_type], query_dzn_path, args.time_limit_ms
                    )
                finally:
                    os.remove(query_dzn_path)

                status = parse_status(proc.stdout)
                stats = parse_stats(proc.stdout)
                nb_paths_match = re.search(r"^result_nb_paths\s*=\s*(\d+);", proc.stdout, re.MULTILINE)

                row.update({
                    "minizinc_command": " ".join(cmd),
                    "solver_time_limit_ms": args.time_limit_ms,
                    "return_code": proc.returncode,
                    "status": status,
                    "result_nb_paths": nb_paths_match.group(1) if nb_paths_match else "",
                    "wall_clock_seconds": round(wall_time, 4),
                })
                row.update(stats)

                if proc.returncode != 0 or status in ("ERROR", "UNKNOWN", "NO_OUTPUT"):
                    stderr_tail = proc.stderr.strip().splitlines()
                    row["error_message"] = stderr_tail[-1] if stderr_tail else ""

                raw_path = os.path.join(args.raw_dir, f"{os.path.splitext(filename)[0]}_{idx}.txt")
                with open(raw_path, "w", encoding="utf-8") as f:
                    f.write("$ " + " ".join(cmd) + "\n\n")
                    f.write("=== STDOUT ===\n")
                    f.write(proc.stdout)
                    f.write("\n=== STDERR ===\n")
                    f.write(proc.stderr)
                row["raw_output_file"] = os.path.relpath(raw_path, REPO_ROOT)

            except Exception as e:
                row["status"] = "SCRIPT_ERROR"
                row["error_message"] = str(e)

            rows.append(row)

    finally:
        with open(INCLUDE_ITYPE_PATH, "w", newline="", encoding="utf-8") as f:
            f.write(original_include_itype)

    fieldnames = []
    for row in rows:
        for key in row:
            if key not in fieldnames:
                fieldnames.append(key)

    with open(args.output, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"\n{len(rows)} run(s) written to {args.output}")


if __name__ == "__main__":
    main()
