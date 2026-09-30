# cp4cm

- [What is cp4cm](#what-is-cp4cm)

- [Installation](#installation)
  - [Minizinc](#minizinc)

- [Basic Usage](#basic-usage)
  - [Datasets](#datasets)
  - [Testing](#testing)
    - [Sample commands](#sample-commands)
    - [Web visualization](#web-visualization)

- [Design Principles and Structure](#design-principles-and-structure)
    - [Modules](#modules)
        - [Digraphs](#digraphs)
        - [Algebraic Structures](#algebraic-structures)
        - [I-types](#i-types)
        - [C-maps](#c-maps)
        - [CMQL Queries](#cmql-queries)
    - [Module Composition](#module-composition)

- [HowTo](#howto)
    - [Add an I-type](#add-an-i-type)
    - [Define a C-map](#define-a-c-map)

<!-- [Remarks](#remarks) -->

- [About](#about)
  - [Authors](#authors)
  - [License](#license)

---

# What is cp4cm

cp4cm is a Constraint Programming (CP) library to build and query cognitive maps inspired by the Cognitive Map Query Language (CMQL).
It is implemented with [Minizinc](https://www.minizinc.org/) - a high-level CP modelling language -
and comes packaged with sample digraphs, influence types and cognitive maps as well as a couple of test scripts which can be run from the command line or the Minizinc IDE.

Background definitions on digraphs, influence types (aka. i-types) and cognitive maps (aka. c-maps) are documented in `cmaps_theory.md`.
The original specification of CMQL is provided in the [PhD thesis of Adrian Robert](https://theses.hal.science/tel-03676196). 

Note: this an alpha release of cp4cm which implements a small subset of CMQL, namely, the influence propagation and aggregation queries.  

---

# Installation

---

## Minizinc

cp4cm assumes Minizinc version 2.8.3 or above. It has first been tested using GECODE but alternative back-end CP solvers may be used (OR-tools, Chuffed, ...).

During our tests, chuffed has been observed to be the best solver to use.

To install the Minizinc distribution and IDE, visit [Minizinc](https://www.minizinc.org/software.html).

---

# Basic Usage

---

## Datasets

Datasets are organized as follows:

- i-types are stored in `./data/itype`

- c-maps are stored in `./data/icmap`

- sample query data are stored in `./data/cmql`.

Datasets are Minizinc data files (`.dzn`) but may alternatively be encoded using [Minizinc JSON format](https://www.minizinc.org/doc-2.8.3/en/spec.html#json-support).

All datasets are commented to help you create your own datasets: a complete documentation of the dataset schemas will be provided in future releases. <!-- TODO -->

---

## Testing

Running cp4cm assumes:

- choosing an i-type dataset in `./data/itype`

- choosing a c-map based on the i-type in `./data/icmap`

- and, optionally, customizing a CMQL query on the c-map `./data/cmql`.

Note. This release of cp4cm requires commenting in or out file inclusion directives present in `./model/include/include_itype.mzn` in order to enable support for the target i-type (this won't be needed in future releases).

For instance, comment out the following lines if you run a query over an enumerated i-type:

`include "./../itype/type/itype_enum_api.mzn";`

in `./model/include/include_ioperations.mzn`

### test_files

Exemple of queries are given in `./test/`.

Four queries are given, two that use a bit of all query data and two that use only the cmql_k_variable predicate.

### Sample commands

Here are sample commands to run from the command line.

1. The query that calculates the influence of the set of paths that start with node `s_node` and end with node `t_node`, on a c-map built with the signed opt-enumerated i-type:

```
minizinc \
-d ./data/itype/itype_opt_enum_signed.dzn \
-d ./data/icmap/icm_S_1_dg_3x3_acyclic_1.dzn \
-d ./data/cmql/cmql_test_s_t_paths.dzn \
./test/test_s_t_paths_new.mzn
```

`./data/cmql/cmql_test_s_t_paths.dzn` sets `nb_paths` and `size_path`, which bound the number and the size of the paths, and the nodes `s_node` and `t_node` of this query.

2. The query that calculates the influence of the paths that go through arc `a`→`b` or through node `c`, on the same c-map:

```
minizinc \
-d ./data/itype/itype_opt_enum_signed.dzn \
-d ./data/icmap/icm_S_1_dg_3x3_acyclic_1.dzn \
-d ./data/cmql/cmql_test_all_primitives.dzn \
./test/test_all_primitives_new.mzn
```

Note: rational i-types do not work yet with these queries.


### Minizinc IDE usage

You may run the same commands from the Minizinc IDE:

1. Open up cp4cm project file `./cp4cm.mzp`.

2. Run model file (ex. `./test/test_s_t_paths_new.mzn`) by pre-selecting first the i-type, c-map and other datafiles.

---

# Design Principles and Structure

The model is split into modules under `./model`. Each module uses the same file layout:

- `<module>_api.mzn`: types and declarations (the module interface),
- `<module>.mzn`: implementation,
- `<module>_display.mzn`: output functions,
- `<module>_imp_api.mzn` (algebra and i-types only): functions the module relies on but does not implement.

Each file starts with a header listing what it defines, declares, implements and uses.

---

## Modules

### Digraphs

`./model/graph`

- `DIGRAPH`: nodes `1..nr_nodes` and arcs `1..nr_arcs`, each arc being a `(t: tail, h: head)` record.
- `ADIGRAPH`: adjacency encoding of a digraph (arc-valued adjacency matrix, tails/heads, in/out arcs, predecessors/successors, sources, sinks) and path counting (`nr_paths`).
- `adigraph_digraph.mzn`: conversions `digraph2adigraph` and `adigraph2digraph`.

### Algebraic Structures

`./model/algebra`

Generic algebra over a domain encoded as arrays of `opt int`, with two binary operations. It handles algebraic properties (commutativity, associativity, neutral and absorbing elements) and the virtual element `<>` of option domains.

The operations themselves (`equality`, `operation1`, `operation2`) are declared in `algebra_imp_api.mzn` and implemented by the i-type module.

### I-types

`./model/itype`

An i-type (`ITYPE`) is the set of influence values labelling the arcs of a c-map, with two operations:

- propagation: combines influences along a path,
- aggregation: combines the influences of several paths.

An influence (`INFLUENCE`) is encoded by an array of `opt int` called i-block: `[P]` (enum case) for enumerated i-types, `[0]`/`[1]` for booleans, `[numerator, denominator]` for rationals. In `opt` i-types, the null influence is the virtual element `<>`.

Supported operations (`ITYPE_OPERATION`): boolean and/or, rational plus/times/min/max, and enumerated operations given as tables in the data (`I_AGGREGATE`, `I_PROPAGATE`). They are all implemented in `itype_ops.mzn`.

An i-type is entirely defined by a data file in `./data/itype`.

### C-maps

`./model/cmap` and `./model/instance`

- `I_CMAP`: input c-map read from the data (`icmap`): name, i-type, node labels (concepts) and arc labels (influences).
- `CMAP`: c-map built from it by `icmap2cmap`, which adds the digraph, the a-digraph and the node × node influence matrix.

The `instance` module builds the c-map used by queries, `instance.cmap`, and checks data consistency (`assertDataset`, `assertInstance`).

### CMQL Queries

A query is a MiniZinc model (see `./test`) that declares path-set variables and constrains them with CMQL primitives over `instance.cmap`.

A set of paths `X` is encoded by:

| Variable | Type | Meaning |
|---|---|---|
| `x_nb_paths` | `var int` | number of non-empty paths |
| `x_paths_length` | `array[PATH_ID] of var int` | number of nodes of each path (`0` if empty) |
| `x_node_paths` | `array[PATH_ID, NODE_PATH] of var opt NODE_ID` | nodes of each path, `<>` after its end |
| `x_arc_paths` | `array[PATH_ID, ARC_PATH] of var opt ARC_ID` | arcs of each path |
| `x_influence_paths` | `array[PATH_ID, NODE_PATH] of var INFLUENCE` | influence of the arc entering each node |

Non-empty paths come first, in strict lexicographic order, and contain no cycle.

The bounds `PATH_ID` and `NODE_PATH` come from `nb_paths` and `size_path` in the query data (`./data/cmql`). With `F_NB_PATH_COUNTING = F_MINIZINC_COUNTING`, they are computed from the c-map instead.

### CMQL Language

The primitives are in `./model/cmql/primitive` and declared in `./model/cmql/primitive_api.mzn`. Below, `X`, `Y` and `Z` stand for the arrays encoding path sets (see `primitive_api.mzn` for the exact arguments).

| Predicate | Meaning |
|---|---|
| `cmql_k_variable(cmap, X)` | `X` is a set of paths of the c-map, with the influences of their arcs |
| `cmql_concatenation(x, y, Z)` | `Z` is the single path made of `x` followed by `y` (each one a node or a single path) |
| `cmql_inclusion(X, Y)` | every path of `X` is a path of `Y` |
| `cmql_addition(X, Y, Z)` | `Z` is the union of `X` and `Y` |
| `cmql_fusion(X, Y, Z)` | `Z` contains the paths made of a path of `X` followed by a path of `Y` starting at its last node |
| `cmql_influence(cmap, X, i)` | `i` is the aggregation, over the paths of `X`, of the influences propagated along each path |

---

## Module Composition

A query model includes:

1. `./model/include/include.mzn`: core modules in dependency order (digraphs, algebra, i-types, c-maps, instance), plus features and visualisation,
2. `./model/include/include_cmql.mzn`: CMQL primitives.

`include_itype.mzn` and `include_ioperations.mzn` are still included by the tests but currently have no effect: all i-type operations are in `itype_ops.mzn`.

A run then combines:

- the i-type data, which defines `itype`,
- the c-map data, which defines `icmap`, converted into `instance.cmap`,
- the query data, which sets the query parameters (`nb_paths`, `size_path`, ...),
- the query model, which posts CMQL primitives on `instance.cmap`.

Optional features `F_*` (debug, path counting, etc.) are declared in `./model/feature/feature_api.mzn`, can be set in any data file, and have their defaults in `feature.mzn`.

---

# HowTo

---

## Add an I-type

Enumerated i-type (no code change):

1. Copy `./data/itype/itype_opt_enum_signed.dzn`.
2. Set the domain `I_DOMAIN`, its symbols `I_`, and the tables `I_AGGREGATE` and `I_PROPAGATE`.
3. Update `itype_algebra`: properties of both operations, and their neutral and absorbing elements.

New kind of operation or sort:

1. Add it to `ITYPE_OPERATION` (and `ITYPE_SORT` for a new sort) in `./model/itype/itype_api.mzn`.
2. Add its case to `iAggregate` and/or `iPropagate` (par and var versions) in `./model/itype/itype_ops.mzn`, and to `iEquals` if equality is not identity.
3. For a new sort, add its display case to `iShow` in `./model/itype/itype.mzn`.
4. Write the data file, keeping the dummy `I_DOMAIN`, `I_`, `I_AGGREGATE` and `I_PROPAGATE` definitions used by the boolean and rational files.

---

## Add a C-map

Create a `.dzn` file in `./data/icmap` that defines `icmap`:

```
icmap = (
	name: "my_cmap",
	itype: itype,
	node_labels: [
		(node:1, concept:(name:"c1")),
		(node:2, concept:(name:"c2")),
	],
	arc_labels: [
		(arc:(t:1, h:2), influence:(iblock:[P])),
	],
);
```

- Nodes are numbered `1..n`, in the order of `node_labels`.
- Loops and duplicate arcs are forbidden.
- Influences use the encoding of the chosen i-type (here `[P]` for the signed enumeration).

Existing files are named `icm_<S|B|R>_1_dg_<nodes>x<arcs>_<name>.dzn` (S: signed enumeration, B: boolean, R: rational).

---

# About

---

## Authors

David Lesaint - david.lesaint@univ-angers.fr
Martin Fleurant - martin.fleurant@etud.univ-angers.fr

---

## License

cp4cm is licensed under the NOLICENSE license.