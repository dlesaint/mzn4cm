# MZN4CM

- [What is mzn4cm](#what-is-mzn4cm)

- [Installation](#installation)

  - [Minizinc](#minizinc)

- [Basic Usage](#basic-usage)

  - [Datasets](#datasets)
  - [Testing](#testing)

- [Model structure](#model-structure)

    - [Modules](#modules)

        - [Digaphs](#digraph)

        - [Algebras](#algebras)

        - [I-types](#i-types)

        - [C-maps](#c-maps)

        - [CMQL Queries](#cmql-queries)

    - [Module Composition](#module-composition)

- [HowTo](#howto)

    - [Define A C-map](#define-a-c-map)

    - [Add A New I-type](#add-a-new-i-type)

- [Remarks](#remarks)

- [About](#about)

  - [Author](#author)
  - [License](#license)

---

# What is mzn4cm

<!--
mzn4cm is a Minizinc library to build and query cognitive maps (aka. cmaps).
It is packaged with sample digraphs, i-types and c-maps and a couple of test scripts which can be run from the command line.

Background definitions on cmaps, digraphs and influence types are documented in `cmaps.html` (converted from `cmaps.md`).
-->

---

# Installation

---

## Minizinc


---

# Basic Usage

---

## Datasets

---

## Testing

Set query parameters, if needed, in `data/cmql/cmql_path_value.dzn`.
Adapt based on your itype the inclusion directives in `model/include/include_ioperations.mzn` and `model/include/include_itype.mzn`.

Examples:

- Opt-enum with no origin/destination in input:

`clear; minizinc test/test_path_value.mzn -d data/icmap/icm_S_1_dg_4x3_chain_1.dzn -d data/itype/itype_opt_enum_signed.dzn`

- Opt-enum with origin/destination set in `data/cmql/cmql_path_value.dzn`:

clear; minizinc test/test_path_value.mzn -d data/icmap/icm_S_1_dg_4x3_chain_1.dzn -d data/itype/itype_opt_enum_signed.dzn -d data/cmql/cmql_path_value.dzn

- Opt-rational with origin/destination set in `data/cmql/cmql_path_value.dzn`:

clear; minizinc test/test_path_value.mzn -d data/icmap/icm_R_1_dg_8x8_routes_1.dzn -d data/itype/itype_opt_rational_plus_times.dzn -d data/cmql/cmql_path_value.dzn


<!--
- (ingore) for runs with multiple cmaps
`clear; minizinc model/main.mzn -d data/icmap/icm_sg_1_dg_3_3_1.dzn -d data/itype/itype_opt_sg.dzn -D icmaps=\[icm_sg_1_dg_3_3_1\]`
-->

---

# Model Structure

---

## Modules

### Digraphs

### Algebras

### I-types

### C-maps

### CMQL Queries

### CMQL Language

---

## Module Composition


---

# HowTo

---

## Define A C-map

---

## Add A New I-type


---

# Remarks

- Since INFLUENCE_SUBDOMAIN typedefed in influence_api as int, user-defined labels are ints (or enum cases since automatically coerced to ints) 
but this is not really satisfactiroy for bool => have to use pseudo-bool.



---

# About

---

## Author

David Lesaint - david.lesaint@univ-angers.fr

---

## License

mzn4cm is licensed under the NOLICENSE license.