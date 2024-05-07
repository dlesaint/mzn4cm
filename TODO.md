# TODO

- [Bugs](#bugs)
- [Consolidation](#consolidation)
- [Extensions](#extensions)


---

# Bugs

- ~~fix path_value for propagation computation~~

- ~~fix itype_rational_plus_times and itype_enum_signed (handling of null itype elements): assertion failed: (1-1) type checking: virtual influence over non-opt i-type (par)~~

---

# Consolidation

- refactor all itype operations files into one single file so that "branching" on a particular i-type does not require commenting in/out some of the inclusion files.

- add smallerThan relation (par/var function) to algebra and itype APIs

- implement script to convert xml fishing-domain cmaps in our json format

- implement script for regression testing on benchmarks = cmql_query X cmql_query_strategy X cmap x itype

- improve/enrich upper-bounds on path number/length

    -- recursive adjacency matrix multiplication actually provides for each pair of nodes a pair-specific upper-bound on the number of paths - not necessarily node- or arc-minimal - of legnth <= number of nodes

    -- a proper mzn functional implementation of depth-first search could do the job to compute and store the exact paths or just to retain their numbers and lengths

- ~~implement GCD constraint for rational itype~~ - determine upper-bound on number of *recursive* computation steps based on input rational arguments

- complete/enrich assertions on all itype signatures based on sorts, operations, algebraic properties and elements

- complete README doc with design architecture and *howto* guidelines

- copy and extend `cmap.md` from php4cm with definitions on itype signatures (eg. many-sorted with min/max based on lex ordering, many-sorted with path length sort and/or path string sort etc.)

- ~~add is_defined_var annotation to enum/bool itype functional constraints~~

- ~~distinguish between the *undefined element* (needed for inexistent algebraic elements) and the *null itype element*~~

- ~~tidy itype API~~

---

# Extensions

- integrate mzn module to support heuristic configuration of the model using flags on the command line

- implement many-sorted itypes on ordered sorts so that < means lexicographic order

- implement feature for automatically upgrading a user-supplied itype with the *path length* sort

- implement feature for automatically upgrading a user-supplied itype with the *number of paths* sort

    - more generally, implement any extension of a n-sort with k new sorts (dimensions), eg augmenting an itype with both path length and path numbers

- implement feature in digraph package for checking acyclicity 

- implement *bounded* rational itype (eg [0%,100%]) allowing non-virtual null elements both for min/max and plus/times

- build proper function API for graphs and cmaps

- add graph functions/constraints: eg. acyclity, connected components

- allow to work on, and query, several cmaps over the same itype simultaneously

- check whether constraint `path_value` may be reified so as to use it in negative context (`not(path_value(...)`)) if needs be

- implement feature for choosing the kind of path minimality: ~~either node minimality or~~ arc minimality

- ~~possibly, allow input parameters giving upper-bounds on path length and path numbers in order to dimension data/var structures properly

- ~~add new restrictions/extensions in the form of side constraints to extend original CQML primitive `path_value`: bounding path length, bounding propagated influence value, membership of extreme or internal nodes and internal arcs, etc~~

- ~~implement CQML primitive for aggregation. Variants:~~

    - ~~rooted (origin and destination nodes fixed) or not (no given origin and destination nodes)~~

    - ~~path bounded (upper-bound on number of paths to aggregate given as primitive argument)~~

