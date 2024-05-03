# mzn4cm

- [What is mzn4cm](#what-is-mzn4cm)

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

# What is mzn4cm

mzn4cm is a Constraint Programming (CP) library to build and query cognitive maps based on the Cognitive Map Query Language (CMQL).
It is implemented with [Minizinc](https://www.minizinc.org/) - a high-level CP modelling language -
and comes packaged with sample digraphs, influence types and cognitive maps as well as a couple of test scripts which can be run from the command line or the Minizinc IDE.

Background definitions on digraphs, influence types (aka. i-types) and cognitive maps (aka. c-maps) are documented in `cmaps_theory.md`).
The original specification of CMQL is provided in the [PhD thesis of Adrian Robert](https://theses.hal.science/tel-03676196). 

Note: this an alpha release of mzn4cp which implements a small subset of CMQL, namely, the influence propagation and aggregation queries.  

---

# Installation

---

## Minizinc

mzn4cm assumes Minizinc version 2.8.3 or above. It has been tested using GECODE but alternative back-end CP solvers may be used (OR-tools, Chuffed, ...).

To install the Minizinc distribution and IDE, visit [Minizinc](https://www.minizinc.org/software.html).

---

# Basic Usage

---

## Datasets

Datasets are organized as follows:

- digraphs are stored in `./data/digraph`

- i-types are stored in `./data/itype`

- c-maps are stored in `./data/icmap`

- sample CMQL query data are stored in `./data/cmql`.

Datasets are Minizinc data files (`.dzn`) but may alternatively be encoded using [Minizinc JSON format](https://www.minizinc.org/doc-2.8.3/en/spec.html#json-support).

All datasets are commented to help you create your own datasets: a complete documentation of the dataset schemas will be provided in future releases. <!-- TODO -->


---

## Testing

Running mzn4cp assumes:

- choosing an i-type dataset in `./data/itype`

- choosing a c-map based on the i-type in `./data/icmap`

- and, optionally, customizing a CMQL query on the c-map `./data/cmql`.

Note. This release of mzn4cp requires commenting in or out file inclusion directives present in `./model/include/include_ioperations.mzn` and `./model/include/include_itype.mzn` in order to enable support for the target i-type (this won't be needed in future releases). <!-- TODO --> 

For instance, comment out the following lines if you run a query over an enumerated i-type:

`include "./../itype/operations/itype_ops_enum.mzn";`

in `./model/include/include_ioperations.mzn`

and

`include "./../itype/operations/itype_ops_enum.mzn";`

in `./model/include/include_ioperations.mzn`


### Sample commands

Here are sample commands to run from the command line.

1. Propage influence using query `path_value` between any pair of nodes of a c-map built with the signed opt-enumerated i-type:

```
minizinc \
-d ./data/itype/itype_opt_enum_signed.dzn \
-d ./data/icmap/icm_S_1_dg_4x3_chain_1.dzn \
./test/test_path_value.mzn
```

2. Run the same query by binding origin and/or destination nodes set in `data/cmql/cmql_path_value.dzn`:

```
minizinc \
-d ./data/itype/itype_opt_enum_signed.dzn \
-d ./data/icmap/icm_S_1_dg_4x3_chain_1.dzn \
-d ./data/cmql/cmql_path_value.dzn \
./test/test_path_value.mzn 
```

3. Switch to a cmap build over the rational opt-itype $(\mathbb{Q}, +, \times)$ by adapting inclusion directives first and then running:

```
minizinc \
-d ./data/icmap/icm_R_1_dg_8x8_routes_1.dzn \
-d ./data/itype/itype_opt_rational_plus_times.dzn \
-d ./data/cmql/cmql_path_value.dzn \
./test/test_path_value.mzn
```


### Web visualization

You may run the same commands from the Minizinc IDE:

1. Open up mzn4cm project file `./mzn4cp.mzp`.

2. Run model file `./test/test_path_value.mzn` by pre-selecting first the i-type and c-map datafiles.

A web page will open showing the c-map and allowing you to browe through the different solutions computed for the query. Note that you may configure the number of requested solutions by ticking the appropriate flag in the IDE configurator.


<!--
- (ingore) for runs with multiple cmaps
`clear; minizinc model/main.mzn -d data/icmap/icm_sg_1_dg_3_3_1.dzn -d data/itype/itype_opt_sg.dzn -D icmaps=\[icm_sg_1_dg_3_3_1\]`
-->

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

mzn4cm is licensed under the NOLICENSE license.