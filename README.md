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

1. The query that calculate the influence of a set of paths that all start with a node `s` and finish with a node `s` of a c-map built with the signed opt-enumerated i-type:

```
minizinc \
-d ./data/itype/itype_opt_enum_signed.dzn \
-d ./data/icmap/icm_S_1_dg_4x3_chain_1.dzn \
-d ./data/cmql/cmql_test_s_t_paths.dzn \
./test/test_s_t_paths.mzn
```

`./data/cmql/cmql_test.dzn` is necessary to bind some variables such as `nb_paths` and `size_paths` used to  bound the size of the variables. `s_node` and `t_node` are necessary for this query only.

2. Switch to a cmap build over the rational opt-itype $(\mathbb{Q}, +, \times)$ by adapting inclusion directives first and then running:

```
minizinc \
-d ./data/icmap/icm_R_1_dg_8x8_routes_1.dzn \
-d ./data/itype/itype_opt_rational_min_max.dzn \
-d ./data/cmql/cmql_test_s_t_paths.dzn \
./test/test_s_t_paths.mzn
```


### Web visualization

You may run the same commands from the Minizinc IDE:

1. Open up cp4cm project file `./cp4cm.mzp`.

2. Run model file (ex. `./test/test_s_t_paths.mzn`) by pre-selecting first the i-type, c-map and other datafiles.

A web page will open showing the c-map and allowing you to browe through the different solutions computed for the query. Note that you may configure the number of requested solutions by ticking the appropriate flag in the IDE configurator.

---

# Design Principles and Structure

---

## Modules

### Digraphs

### Algebraic Structures

### I-types

### C-maps

### CMQL Queries

### CMQL Language

---

## Module Composition


---

# HowTo


---

## Add an I-type

---

## Add a C-map


<!--
---

# Remarks

- Since INFLUENCE_SUBDOMAIN is typedefed as `int` in influence_api, user-defined labels are ints (or enum cases since automatically coerced to ints) 
but this is not really satisfactory for bool => have to use pseudo-bool.

-->


---

# About

---

## Authors

David Lesaint - david.lesaint@univ-angers.fr
Martin Fleurant - martin.fleurant@etud.univ-angers.fr

---

## License

cp4cm is licensed under the NOLICENSE license.