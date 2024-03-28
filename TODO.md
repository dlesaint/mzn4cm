# TODO

- [Bugs](#bugs)
- [Consolidation](#consolidation)
- [Extensions](#extensions)


---

# Bugs

- ~~fix path_value for propagation computation~~

- fix itype_rational_plus_times and itype_enum_signed (handling of null itype elements)

    -- assertion failed: (1-1) type checking: virtual influence over non-opt i-type (par)

---

# Consolidation

- add is_defined_var annotation to enum/bool itype functional constraints

- ~~implement GCD constraint for rational itype~~ - determine upper-bound on number of *recursive* computation steps based on input rational arguments

- distinguish between the *undefined element* (needed for inexistent algebraic elements) and the *null itype element*

- enrich assertions on all itype signatures based on sorts, operations, algebraic properties and elements

- tidy itype API

- refactor all itype operations files into one single file if feasible

- add smallerThan relation (par/var function) to algebra and itype APIs

- implement script for regression testing on benchmarks = cmql_path_value X cmap x itype

- write README doc including design architecture and *howto* guidelines

- copy and extend `cmap.md` from php4cm with definitions on itype signatures (sorts, etc)

---

# Extensions

- implement CQML primitive for aggregation. Variants:

    - rooted (origin and destination nodes fixed) or not (no given origin and destination nodes)

    - path bounded (upper-bound on number of paths to aggregate given as primitive argument)

- implement *bounded* rational itype (eg [0%,100%]) allowing non-virtual null elements both for min/max and plus/times

- implement poly-sort itypes on ordered sorts so that < means lexicographic order

- implement feature for choosing the kind of path minimality: either node minimality or arc minimality

- implement feature for automatically upgrading a user-supplied itype with the *path length* sort

- implement feature for automatically upgrading a user-supplied itype with the *number of paths* sort

    - more generally, implement any extension of a n-sort with k new sorts (dimensions), eg augmenting an itype with both path length and path numbers

- implement feature in digraph package for checking acyclicity 

- build proper function API for graphs and cmaps

- add graph functions/constraints: eg, acyclity, connected components

- possibly, allow input parameters iving upper-bounds on path length and path numbers in order to dimension data/var structures properly

- allow to work and query several cmaps over the same itype simultaneously

- check whether constraint `path_value` may be reified so as to use it in negative context (`not(path_value(...)`)) if needs be

- add new restrictions/extensions in th eform of side constraints to extend original CQML primitive `path_value`

    - bounding path length

    - bounding propagated influence value

    - membership of extreme or internal nodes and internal arcs

    - etc
