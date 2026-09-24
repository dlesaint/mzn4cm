### THIS FILE WAS MADE WITH AI

"""Runs test/test_s_t_paths.mzn with the Chuffed solver over a batch of c-maps
(.dzn icmap files) and records solver statistics in a spreadsheet-friendly CSV file.

For each icmap file:
  - the influence type (enum or int/rational) is detected from the arc labels,
  - the matching i-type data file is selected (itype_opt_enum_signed.dzn or
    itype_opt_rational_min_max.dzn), and model/include/include_itype.mzn is
    toggled accordingly,
  - nb_paths and size_path are ESTIMATED from the graph's size and density
    (closed-form random-graph formulas, simple/acyclic paths only, capped by
    --max-nb-paths / --max-size-path so every graph can be compiled),
  - s_node and t_node are picked randomly among the graph's nodes,
  - minizinc is run with the Chuffed solver and full statistics enabled.

Usage:
    python run_s_t_paths_tests.py [-d data/icmap/kifanlo] [-o test/results/s_t_paths_results.csv]
"""
import argparse
import csv
import math
import os
import random
import re
import subprocess
import sys
import tempfile
import threading
import time
from datetime import datetime, timezone

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MODEL_PATH = os.path.join(REPO_ROOT, "test", "test_s_t_paths.mzn")
INCLUDE_ITYPE_PATH = os.path.join(REPO_ROOT, "model", "include", "include_itype.mzn")
ITYPE_DATA = {
    "enum": os.path.join(REPO_ROOT, "data", "itype", "itype_opt_enum_signed.dzn"),
    "int": os.path.join(REPO_ROOT, "data", "itype", "itype_opt_rational_min_max.dzn"),
}

STAT_RE = re.compile(r"^%%%mzn-stat:\s*([\w]+)=(.*)$", re.MULTILINE)


def _relpath(path, start):
    try:
        return os.path.relpath(path, start)
    except ValueError:
        return os.path.abspath(path)


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


# -------------------- graph parsing --------------------

NODE_RE = re.compile(r"\(node:(\d+),")
ARC_RE = re.compile(r"\(arc:\(t:(\d+), h:(\d+)\)")


def parse_graph(icmap_text):
    """Returns (n_nodes, arcs) where arcs is a list of (tail, head) pairs."""
    n_nodes = len(NODE_RE.findall(icmap_text))
    arcs = [(int(t), int(h)) for t, h in ARC_RE.findall(icmap_text)]
    return n_nodes, arcs


def is_acyclic(n_nodes, arcs):
    """Kahn's algorithm (node ids are 1..n_nodes)."""
    adj = [[] for _ in range(n_nodes + 1)]
    in_degree = [0] * (n_nodes + 1)
    for tail, head in arcs:
        adj[tail].append(head)
        in_degree[head] += 1
    stack = [v for v in range(1, n_nodes + 1) if in_degree[v] == 0]
    visited = 0
    while stack:
        v = stack.pop()
        visited += 1
        for w in adj[v]:
            in_degree[w] -= 1
            if in_degree[w] == 0:
                stack.append(w)
    return visited == n_nodes


# -------------------- nb_paths / size_path estimation --------------------
#
# Only simple paths (no repeated node) matter, also in cyclic graphs, since the
# model forbids node repetition inside a path. The graph is modelled as a random
# graph with the observed size n and density p = arcs / (n*(n-1)):
#   - general (cyclic) digraph: every ordered pair is an arc with probability p
#   - acyclic graph: arcs go forward in a topological order, each of the
#     n*(n-1)/2 forward pairs is an arc with probability q = 2p
# All computations are done in log space so huge values never overflow; results
# are then capped, since the model size grows with nb_paths (quadratically, due
# to the fusion predicate) and size_path.

def _log_falling_factorial(m, r):
    """log(m! / (m-r)!) = log of the number of ordered selections of r among m."""
    return math.lgamma(m + 1) - math.lgamma(m - r + 1)


def _log_binomial(m, r):
    return math.lgamma(m + 1) - math.lgamma(r + 1) - math.lgamma(m - r + 1)


# MiniZinc refuses arrays with more than this many elements ("array size ...
# exceeds maximum allowed size (1073741823)"). The model declares P x P arrays
# (xyID in the fusion predicate) and P x N arrays of influences (up to 2
# components each), with P = nb_paths and N = size_path.
MZN_MAX_ARRAY_SIZE = 2**30 - 1


def apply_array_limit(nb_paths, size_path):
    """Reduces nb_paths so that no array of the model exceeds MiniZinc's size limit."""
    limited = False
    if nb_paths > math.isqrt(MZN_MAX_ARRAY_SIZE):
        nb_paths = math.isqrt(MZN_MAX_ARRAY_SIZE)
        limited = True
    if nb_paths * size_path * 2 > MZN_MAX_ARRAY_SIZE:
        nb_paths = max(1, MZN_MAX_ARRAY_SIZE // (2 * size_path))
        limited = True
    return nb_paths, size_path, limited


def estimate_path_bounds(n_nodes, n_arcs, acyclic, min_nb_paths, max_nb_paths, max_size_path):
    """Estimates (nb_paths, size_path, details) from graph size and density.

    nb_paths  ~ max number of simple paths between two nodes.
    size_path ~ max number of NODES in a simple path.
    """
    n = n_nodes
    # a cap <= 0 means "no artificial cap": only MiniZinc's array size limit applies
    max_nb_paths = max_nb_paths if max_nb_paths > 0 else MZN_MAX_ARRAY_SIZE
    max_size_path = max_size_path if max_size_path > 0 else MZN_MAX_ARRAY_SIZE
    max_arcs = n * (n - 1)
    p = n_arcs / max_arcs if max_arcs > 0 else 0.0
    q = min(1.0, 2.0 * p)  # forward-pair probability for acyclic graphs

    details = {"density": p}
    if n < 2 or n_arcs == 0:
        details.update({"expected_paths": 0.0, "longest_path_nodes_uncapped": 1})
        return max(1, min_nb_paths), 2, details

    # ---- expected number of simple s->t paths (for the best pair if acyclic)
    if acyclic:
        # pair (1, n): sum_k C(n-2, k-1) q^k = q (1+q)^(n-2)
        log_expected = math.log(q) + (n - 2) * math.log1p(q)
    else:
        # sum_k P(n-2, k-1) p^k, k = 1..n-1
        log_terms = [_log_falling_factorial(n - 2, k - 1) + k * math.log(p) for k in range(1, n)]
        top = max(log_terms)
        log_expected = top + math.log(sum(math.exp(t - top) for t in log_terms))

    if log_expected > math.log(max_nb_paths):
        nb_paths_uncapped = None
        nb_paths = max_nb_paths
        expected = float("inf")
    else:
        expected = math.exp(log_expected)
        # Poisson-style margin (mean + 3 sigma) since the max over all pairs exceeds the mean
        nb_paths_uncapped = math.ceil(expected + 3.0 * math.sqrt(expected))
        nb_paths = min(max(nb_paths_uncapped, min_nb_paths), max_nb_paths)

    # ---- longest simple path: largest k (arcs) whose expected count in the whole graph is >= 1
    longest_arcs = 1
    for k in range(1, n):
        if acyclic:
            log_count = _log_binomial(n, k + 1) + k * math.log(q)
        else:
            log_count = _log_falling_factorial(n, k + 1) + k * math.log(p)
        if log_count >= 0.0:
            longest_arcs = k
    longest_nodes = longest_arcs + 1
    size_path = max(2, min(longest_nodes, n, max_size_path))

    nb_paths, size_path, array_limit_applied = apply_array_limit(nb_paths, size_path)

    details.update({
        "array_limit_applied": array_limit_applied,
        "expected_paths": expected,
        "nb_paths_uncapped": nb_paths_uncapped,
        "longest_path_nodes_uncapped": longest_nodes,
        "nb_paths_capped": nb_paths_uncapped is None or nb_paths_uncapped > max_nb_paths,
        "size_path_capped": longest_nodes > size_path,
    })
    return nb_paths, size_path, details


# -------------------- minizinc run + output parsing --------------------

def parse_status(stdout):
    if "=====UNSATISFIABLE=====" in stdout:
        return "UNSATISFIABLE"
    if "=====ERROR=====" in stdout:
        return "ERROR"
    if "=====UNKNOWN=====" in stdout:
        # no flattening statistics => the time limit was hit while compiling
        return "UNKNOWN" if "%%%mzn-stat: flatTime" in stdout else "UNKNOWN_DURING_COMPILATION"
    if "==========" in stdout:
        return "OPTIMAL"
    if "result_nb_paths" in stdout:
        return "SATISFIABLE_INCOMPLETE"
    if "% Time limit exceeded" in stdout:
        return "TIME_LIMIT_NO_SOLUTION"
    return "NO_OUTPUT"


def parse_stats(stdout):
    stats = {}
    for key, value in STAT_RE.findall(stdout):
        stats[key] = value.strip().strip('"')
    return stats


# -------------------- memory guard (Windows job object) --------------------
#
# Every minizinc run is put in a Windows job object that (a) caps the committed
# memory of the whole process tree (minizinc + fzn-chuffed), so a pathological
# model cannot exhaust the machine, (b) reports the peak memory of the run and
# (c) kills every process of the tree when the job is closed. Without Windows
# (or if the job cannot be created) the run simply goes unguarded.

try:
    import ctypes

    class _IoCounters(ctypes.Structure):
        _fields_ = [(name, ctypes.c_ulonglong) for name in (
            "ReadOperationCount", "WriteOperationCount", "OtherOperationCount",
            "ReadTransferCount", "WriteTransferCount", "OtherTransferCount")]

    class _BasicLimits(ctypes.Structure):
        _fields_ = [
            ("PerProcessUserTimeLimit", ctypes.c_int64),
            ("PerJobUserTimeLimit", ctypes.c_int64),
            ("LimitFlags", ctypes.c_uint32),
            ("MinimumWorkingSetSize", ctypes.c_size_t),
            ("MaximumWorkingSetSize", ctypes.c_size_t),
            ("ActiveProcessLimit", ctypes.c_uint32),
            ("Affinity", ctypes.c_size_t),
            ("PriorityClass", ctypes.c_uint32),
            ("SchedulingClass", ctypes.c_uint32),
        ]

    class _ExtendedLimits(ctypes.Structure):
        _fields_ = [
            ("BasicLimitInformation", _BasicLimits),
            ("IoInfo", _IoCounters),
            ("ProcessMemoryLimit", ctypes.c_size_t),
            ("JobMemoryLimit", ctypes.c_size_t),
            ("PeakProcessMemoryUsed", ctypes.c_size_t),
            ("PeakJobMemoryUsed", ctypes.c_size_t),
        ]

    _JOB_EXTENDED_LIMIT_INFO = 9
    _LIMIT_JOB_MEMORY = 0x00000200
    _LIMIT_KILL_ON_JOB_CLOSE = 0x00002000

    _kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    _kernel32.CreateJobObjectW.restype = ctypes.c_void_p
    _kernel32.CreateJobObjectW.argtypes = [ctypes.c_void_p, ctypes.c_wchar_p]
    _kernel32.SetInformationJobObject.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint32]
    _kernel32.QueryInformationJobObject.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p]
    _kernel32.AssignProcessToJobObject.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    _kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
    _JOBS_AVAILABLE = True
except (ImportError, AttributeError, OSError):
    _JOBS_AVAILABLE = False


def _create_memory_job(proc, max_memory_gb):
    """Puts proc in a new job object limited to max_memory_gb; returns the job handle or None."""
    if not _JOBS_AVAILABLE:
        return None
    try:
        job = _kernel32.CreateJobObjectW(None, None)
        if not job:
            return None
        info = _ExtendedLimits()
        info.BasicLimitInformation.LimitFlags = _LIMIT_JOB_MEMORY | _LIMIT_KILL_ON_JOB_CLOSE
        info.JobMemoryLimit = int(max_memory_gb * 1024**3)
        if not _kernel32.SetInformationJobObject(job, _JOB_EXTENDED_LIMIT_INFO, ctypes.byref(info), ctypes.sizeof(info)):
            _kernel32.CloseHandle(job)
            return None
        if not _kernel32.AssignProcessToJobObject(job, int(proc._handle)):
            _kernel32.CloseHandle(job)
            return None
        return job
    except Exception:
        return None


def _job_peak_memory_mb(job):
    info = _ExtendedLimits()
    if not _kernel32.QueryInformationJobObject(job, _JOB_EXTENDED_LIMIT_INFO, ctypes.byref(info), ctypes.sizeof(info), None):
        return None
    return info.PeakJobMemoryUsed / 1024**2


def run_minizinc(icmap_path, itype_data_path, query_dzn_path, time_limit_ms, hard_timeout_s,
                 model_path=MODEL_PATH, max_memory_gb=None):
    """Runs minizinc and returns (cmd, CompletedProcess, wall_time, hard_timed_out, info).

    Safety nets:
      - MiniZinc 2.10.1 on Windows has been seen to stay alive (idle) forever
        after Chuffed stops on --time-limit. As soon as the solver reports
        "% Time limit exceeded", everything useful (solution + statistics) has
        already been printed, so the process is killed after a short grace period
        and the output is kept;
      - a hard wall-clock timeout kills the process if it produces nothing for too
        long (e.g. a pathological flattening); then hard_timed_out is True;
      - the whole process tree lives in a job object capped at max_memory_gb (see
        above); info["peak_memory_mb"] is the peak memory of the tree and
        info["memory_limit_hit"] tells whether the cap was (almost) reached.
    """
    cmd = [
        "minizinc", model_path,
        "-d", icmap_path,
        "-d", itype_data_path,
        "-d", query_dzn_path,
        "--solver", "Chuffed",
        "-s",
        "--time-limit", str(time_limit_ms),
    ]
    start = time.perf_counter()
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    job = _create_memory_job(proc, max_memory_gb) if max_memory_gb else None

    stderr_chunks = []
    stderr_thread = threading.Thread(target=lambda: stderr_chunks.append(proc.stderr.read()), daemon=True)
    stderr_thread.start()

    state = {"hard_timed_out": False}

    def _hard_kill():
        state["hard_timed_out"] = True
        proc.kill()

    timer = threading.Timer(hard_timeout_s, _hard_kill)
    timer.start()

    stdout_lines = []
    time_limit_marker_seen = False
    for line in proc.stdout:
        stdout_lines.append(line)
        if line.startswith("% Time limit exceeded"):
            time_limit_marker_seen = True
            break

    if time_limit_marker_seen:
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
        returncode = 0
    else:
        proc.wait()
        returncode = proc.returncode
    timer.cancel()
    stderr_thread.join(timeout=5)

    info = {"peak_memory_mb": None, "memory_limit_hit": False}
    if job:
        peak = _job_peak_memory_mb(job)
        if peak is not None:
            info["peak_memory_mb"] = round(peak)
            info["memory_limit_hit"] = peak >= 0.95 * max_memory_gb * 1024
        _kernel32.CloseHandle(job)  # kills any process of the tree still alive

    wall_time = time.perf_counter() - start
    completed = subprocess.CompletedProcess(
        cmd, returncode, "".join(stdout_lines), "".join(stderr_chunks)
    )
    return cmd, completed, wall_time, state["hard_timed_out"], info


# -------------------- main --------------------

def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-d", "--graphs-dir", nargs="+",
                         default=[os.path.join(REPO_ROOT, "data", "icmap", "kifanlo")],
                         help="One or more directories of .dzn icmap files to test, searched recursively "
                              "(default: data/icmap/kifanlo)")
    parser.add_argument("-o", "--output", default=os.path.join(REPO_ROOT, "test", "results", "s_t_paths_results.csv"),
                         help="Path to the output CSV file")
    parser.add_argument("--raw-dir", default=os.path.join(REPO_ROOT, "test", "results", "raw"),
                         help="Directory where the full raw minizinc output of each run is saved")
    parser.add_argument("--time-limit-ms", type=int, default=300000,
                         help="MiniZinc time limit in milliseconds (compilation + solving)")
    parser.add_argument("--hard-timeout-s", type=float, default=420.0,
                         help="Hard wall-clock timeout (seconds) covering the whole minizinc process "
                              "(flattening + solving); the run is killed and marked TIMEOUT if exceeded")
    parser.add_argument("--min-nb-paths", type=int, default=3,
                         help="Lower bound on the estimated nb_paths")
    parser.add_argument("--max-nb-paths", type=int, default=10,
                         help="Cap on the estimated nb_paths (the model grows quadratically with it)")
    parser.add_argument("--max-size-path", type=int, default=10,
                         help="Cap on the estimated size_path (max number of nodes in a path)")
    parser.add_argument("--seed", type=int, default=None, help="Random seed for s_node/t_node selection")
    parser.add_argument("--limit", type=int, default=None, help="Only process the first N files (for a quick smoke test)")
    parser.add_argument("--repetitions", type=int, default=1,
                         help="Number of independent runs per icmap file, each with a freshly random s_node/t_node "
                              "(nb_paths/size_path are estimated once per file and reused across repetitions)")
    parser.add_argument("--max-memory-gb", type=float, default=10.0,
                         help="Memory cap (GB of committed memory) for each minizinc run tree (Windows job object); "
                              "0 disables the guard")
    parser.add_argument("--label", default="",
                         help="Free text stored in the run_label column (e.g. the bounds mode of this batch)")
    parser.add_argument("--skip-include-toggle", action="store_true",
                         help="Do not touch model/include/include_itype.mzn (needed when several batches run "
                              "concurrently, since they would race on that file)")
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    os.makedirs(args.raw_dir, exist_ok=True)

    files = []
    for graphs_dir in args.graphs_dir:
        for root, _, filenames in os.walk(graphs_dir):
            for fn in filenames:
                if fn.endswith(".dzn"):
                    files.append(os.path.join(root, fn))
    files.sort()
    if args.limit:
        files = files[: args.limit]

    original_include_itype = None
    if not args.skip_include_toggle:
        with open(INCLUDE_ITYPE_PATH, "r", newline="", encoding="utf-8") as f:
            original_include_itype = f.read()

    rows = []
    try:
        for idx, icmap_path in enumerate(files, start=1):
            filename = _relpath(icmap_path, REPO_ROOT)
            print(f"[{idx}/{len(files)}] {filename}")

            with open(icmap_path, "r", encoding="utf-8") as f:
                icmap_text = f.read()

            base_row = {
                "file": filename,
                "path": icmap_path,
            }

            try:
                influence_type = detect_influence_type(icmap_text)
                n_nodes, arcs = parse_graph(icmap_text)
                n_arcs = len(arcs)
                max_arcs = n_nodes * (n_nodes - 1)  # complete digraph, no self-loops
                density = n_arcs / max_arcs if max_arcs > 0 else 0.0
                acyclic = is_acyclic(n_nodes, arcs)

                base_row.update({
                    "influence_type": influence_type,
                    "itype_data_file": os.path.basename(ITYPE_DATA[influence_type]),
                    "n_nodes": n_nodes,
                    "n_arcs": n_arcs,
                    "density": round(density, 6),
                    "is_acyclic": acyclic,
                })

                if not args.skip_include_toggle:
                    set_include_itype(influence_type)

                estimate_started = time.perf_counter()
                nb_paths, size_path, details = estimate_path_bounds(
                    n_nodes, n_arcs, acyclic, args.min_nb_paths, args.max_nb_paths, args.max_size_path
                )
                base_row.update({
                    "run_label": args.label,
                    "array_limit_applied": details.get("array_limit_applied"),
                    "nb_paths_param": nb_paths,
                    "size_path_param": size_path,
                    "expected_paths": details.get("expected_paths"),
                    "nb_paths_uncapped": details.get("nb_paths_uncapped"),
                    "longest_path_nodes_uncapped": details.get("longest_path_nodes_uncapped"),
                    "nb_paths_capped": details.get("nb_paths_capped"),
                    "size_path_capped": details.get("size_path_capped"),
                    "path_calc_seconds": round(time.perf_counter() - estimate_started, 4),
                })

            except Exception as e:
                base_row["status"] = "SCRIPT_ERROR"
                base_row["error_message"] = str(e)
                base_row["timestamp"] = datetime.now(timezone.utc).isoformat()
                rows.append(base_row)
                continue

            for rep in range(1, args.repetitions + 1):
                row = dict(base_row)
                row["repetition"] = rep
                row["timestamp"] = datetime.now(timezone.utc).isoformat()
                if args.repetitions > 1:
                    print(f"    rep {rep}/{args.repetitions}")

                try:
                    s_node, t_node = random.sample(range(1, n_nodes + 1), 2)
                    row.update({"s_node": s_node, "t_node": t_node})

                    fd, query_dzn_path = tempfile.mkstemp(suffix=".dzn", prefix="s_t_paths_query_")
                    try:
                        with os.fdopen(fd, "w", encoding="utf-8") as f:
                            f.write(f"s_node={s_node};\n")
                            f.write(f"t_node={t_node};\n")
                            f.write(f"nb_paths={nb_paths};\n")
                            f.write(f"size_path={size_path};\n")

                        cmd, proc, wall_time, timed_out, mem_info = run_minizinc(
                            icmap_path, ITYPE_DATA[influence_type], query_dzn_path,
                            args.time_limit_ms, args.hard_timeout_s,
                            max_memory_gb=args.max_memory_gb or None
                        )
                    finally:
                        os.remove(query_dzn_path)

                    row.update({
                        "minizinc_command": " ".join(cmd),
                        "solver_time_limit_ms": args.time_limit_ms,
                        "hard_timeout_s": args.hard_timeout_s,
                        "wall_clock_seconds": round(wall_time, 4),
                        "peak_memory_mb": mem_info["peak_memory_mb"],
                        "memory_limit_gb": args.max_memory_gb,
                    })

                    if timed_out:
                        row.update({
                            "status": "MEMORY_LIMIT" if mem_info["memory_limit_hit"] else "TIMEOUT",
                            "error_message": f"minizinc process killed after exceeding the {args.hard_timeout_s}s hard timeout",
                        })
                    else:
                        status = parse_status(proc.stdout)
                        if mem_info["memory_limit_hit"] and status in (
                                "ERROR", "NO_OUTPUT", "UNKNOWN", "UNKNOWN_DURING_COMPILATION"):
                            status = "MEMORY_LIMIT"
                        stats = parse_stats(proc.stdout)
                        nb_paths_match = re.search(r"^result_nb_paths\s*=\s*(\d+);", proc.stdout, re.MULTILINE)

                        row.update({
                            "return_code": proc.returncode,
                            "time_limit_reached": "% Time limit exceeded" in proc.stdout,
                            "status": status,
                            "result_nb_paths": nb_paths_match.group(1) if nb_paths_match else "",
                        })
                        row.update(stats)

                        if proc.returncode != 0 or status in ("ERROR", "UNKNOWN", "NO_OUTPUT"):
                            stderr_tail = proc.stderr.strip().splitlines()
                            row["error_message"] = stderr_tail[-1] if stderr_tail else ""

                        base_name = os.path.splitext(os.path.basename(icmap_path))[0]
                        raw_path = os.path.join(args.raw_dir, f"{base_name}_{idx}_{rep}.txt")
                        with open(raw_path, "w", encoding="utf-8") as f:
                            f.write("$ " + " ".join(cmd) + "\n\n")
                            f.write("=== STDOUT ===\n")
                            f.write(proc.stdout)
                            f.write("\n=== STDERR ===\n")
                            f.write(proc.stderr)
                        row["raw_output_file"] = _relpath(raw_path, REPO_ROOT)

                except Exception as e:
                    row["status"] = "SCRIPT_ERROR"
                    row["error_message"] = str(e)

                rows.append(row)

    finally:
        if original_include_itype is not None:
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
