# Cognitive Maps - Definitions

---


## Contents

- [Digraphs](#digraphs)

- [Influence Types](#influence-types)

- [Cognitive Maps](#cognitive-maps)

- [Algebraic Background](#algebraic-background)


---

## Digraphs

**Definition 1.1** A *digraph* $G$ is a triple $(V,E,f)$ such that:

- $V$ is a set of *nodes*

- $E$ is set of *arcs*

- $f: E \rightarrow V\times V$ is a function mapping each arc to an ordered pair of nodes.

Let $e$ be an arc of $G$ such that $f(e)=(x,y)$.

- $x$ is called the *tail* of $e$.

- $y$ is called the *head* of $e$.

- $e$ is said to be an *outgoing arc* of $x$.

- $e$ is said to be an *incoming arc* of $y$.

**Definition 1.2** $G$ is called a *simple digraph* if it satisfies the following conditions:

- [no loops] $\forall e \in E, v \in V, f(e)\neq(v,v)$

- [no duplicate arcs] $\forall e_i, e_j \in E, e_i\neq e_j \implies f(e_i)\neq f(e_j)$.

**Definition 1.3** A *dipath* is a finite non-empty sequence $(e_1,\ldots  ,e_m)$ of m arcs of $G$ $(m>0)$ such that:

- [node join] $\forall i=1\ldots  m-1$, the head of $e_i$ is the tail of $e_{i+1}$

- [different arcs] $\forall 1\leq i<j\leq m, e_i\neq e_j$.

The *node sequence* of a dipath $p=(e_1,\ldots  ,e_m)$ is the sequence of nodes $(v_1,\ldots  ,v_{m+1})$ such that $f(e_i)=(v_{i},v_{i+1})$ $(i=1\ldots  m)$.

- $p$ is called a path from $v_{1}$ to $v_{m+1}$

- $v_{1}$ is called the *origin* of $p$

- $v_{m+1}$ is called the *destination* of $p$.

**Definition 1.4** A dipath with node sequence $(v_1,\ldots  ,v_n)$ is called a *simple dipath* if

- [distinct nodes] $\forall 1\leq i<j\leq n, v_i\neq v_j$.

We call *empty dipath* the empty sequence of arcs $()$.

- The node sequence of the empty dipath is the empty sequence $()$.

- The empty dipath is a simple dipath.

We call *loose dipath* any sequence of arcs which is a dipath or the empty dipath.

Let $x$, $y$ be nodes of $G$.

- $x$ is said to be a *direct predecessor* of $y$ if there exists $e\in E$ such that $f(e)=(x,y)$.

- $y$ is said to be a *direct successor* of $x$ if there exists $e\in E$ such that $f(e)=(x,y)$.

- $y$ is said to be *reachable* from $x$ is there exists a dipath from $x$ to $y$.

**Definition 1.5** A digraph is *cyclic* if there exists nodes $x$ and $y$ such that:

- $x$ is reachable from $y$

- $y$ is reachable from $x$.

**Definition 1.6** A digraph is *strongly-connected* if every node is reachable from any node including itself.

Let $x$ be a node of $G$.

- $x$ is a *source* of $G$ if it has no incoming arcs.

- $x$ is a *sink* of $G$ if it has no outgoing arcs.

- The *in-degree* of $x$ is the number of its incoming arcs.

- The *out-degree* of $x$ is the number of its outgoing arcs.

- The *in-degree* of $G$ is the maximum in-degree of its nodes.

- The *out-degree* of $G$ is the maximum out-degree of its nodes.





---

## Influence Types


**Definition 2.1** An influence type is a commutative semi-ring $(I,(+,<>),(*,\_))$ such that

- $I$ is a non-empty set of elements called *influences*

- addition $+$ over $I$ is called *aggregation*

- multiplication $*$ over I is called *propagation*

- the neutral element $<>$ for aggregation is called *absent influence*

- the neutral element $\_$ for propagation is called *null influence*.

By definition of a commutative semi-ring,

- $(I,+,<>)$ is a commutative monoid

- $(I,*,\_)$ is a commutative monoid

- $<>$ is the absorbing element for propagation

- and propagation distributes over aggregation.


---

## Cognitive maps


**Definition 3.1** A *cmap* M is a tuple $(G,C,I,L_v,L_e)$ such that:

- $G$ is a digraph $(V,E,f)$,

- $C$ is a set of *concepts*,

- $I$ is an *influence type*

- $L_v$ and $L_e$ are graph labeling functions such that

    - $L_v: V \rightarrow C$ is a one-to-one function mapping each node of $G$ to a concept in $C$.

    - $L_e: E \rightarrow I$ is a function mapping each arc of $G$ to an influence, ie. an element of $I$.

Given a cmap,

- The influence of a loose dipath of length $n\geq 0$ is the image by propagation of the $n$-uple of influences labeling the sequence of arcs in the dipath.

- The influence of a node $v_1$ on a node $v_2$ for which there exists $m\geq 0$ dipaths from $v_1$ to $v_2$ in $G$ is the image by aggregation of the $m$-uple of influences associated with the dipaths.




---

## Algebraic Background


### Magmas
 
**Definition 4.1** A *magma* [fr-FR: magma] $(S,*)$ is a set $S$ equipped with a binary operation $*$ and closed under this operation (ie. $*$ is a map $*:S\times S\rightarrow S$).


### Semi-groups and quasi-groups

Given a magma $(S,*)$, $*$ is *associative* iff

- [associativity] $\forall  a,b,c \in S: (a*b)*c = a*(b*c)$. 

**Definition 4.2** A *semi-group* [fr-FR: semi-groupe] is an associative magma.

**Definition 4.3** A *quasi-group* [fr-FR: quasigroupe] is a magma $(S,*)$ such that left- and right-multiplication are bijective:

- [divisibility (aka. Latin square property)] $\forall a,b \in S, \exists !x,y \in S: a*x=b \wedge y*a=b$.

An element $a$ of a magma $(S,*)$ is *cancellative* [fr-FR: régulier|simplifiable] if

- [cancellative element] $\forall b,c \in S: (a*b = a*c \vee b*a = c*a) \implies b=c$.

A *cancellative magma* is a magma $(S,*)$ whose elements are cancellative:

- [cancellability] $\forall a,b,c \in S: (a*b=a*c \vee b*a=c*a) \implies b=c$.

Note. A quasi-group may alternatively be defined as a cancellative magma $(S,*)$ such that 

- $\forall a,b \in S, \exists x,y \in S: a*x=b \wedge y*a=b$.


### Monoids and unital magmas

A *neutral element* for a magma $(S,*)$ is an element $1$ of $S$ that leaves unchanged every element of $S$ when combined with $*$:

- $\forall  a \in S: a*1 = a = 1*a$.

Note. A magma can have at most one neutral element (aka. identity element).


**Definition 4.4** A *unital magma* [fr-FR: magma unifère] is a magma having a neutral element.

**Definition 4.5** A *monoid* [fr-FR: monoïde] is a semi-group having a neutral element.

Equivalently, a monoid is an associative unital magma.


### Loops

Let $a$ and $b$ be elements of a unital magma $(S,*,1)$.

- [left-inverse] $a$ is a *left-inverse* of $b$ if $a*b = 1$.

- [right-inverse] $a$ is a *right-inverse* of $b$ if $b*a = 1$.

- [inverse] $a$ is the *inverse* of $b$ if it is both the left-inverse and right-inverse of $b$.

**Definition 4.6** A *loop* [fr-FR: boucle] is a quasi-group having a neutral element.

Equivalently, a loop is a unital magma such that left- and right-multiplication are bijective.

Note. In a loop, every element has unique left- and right-inverses which may not be equal.

Note. An element may have no inverse in a semi-group (eg. $(\mathbb{N},+)$). 


### Groups

**Definition 4.7** A *group* is a monoid for which every element has an inverse.

Equivalently, a group is an associative loop.

Note. A non-empty group is an associative quasi-group. Indeed, an associative quasigroup is either empty or is a group. If it is not empty, the invertibility of * combined with associativity implies the existence of an identity element, which then implies the existence of inverse elements, thus satisfying all three requirements of a group (associativity, identity, invertibility).


### Semi-rings and beyond

An *absorbing element* for magma $(S,*)$ is an element $0$ of $S$ that is left unchanged by combination by $*$ with any element of $S$:

- [absorbing element] $\forall  a \in S: a*0 = 0 = 0*a$.

Note. A magma can have at most one absorbing element (aka. zero element).

$*$ is *commutative* iff

- [commutativity] $\forall  a,b \in S: a*b = b*a$.

Given two binary operations $*:S\times S\rightarrow S$ and $+:S\times S\rightarrow S$, $*$ is *distributive* over $+$ iff

- $\forall  a,b,c \in S: a*(b+c) = (a*b) + (a*c)$  

- $\forall  a,b,c \in S: (b+c)*a = (b*a) + (c*a)$.
 

**Definition 4.8** A *semi-ring* [fr-FR: demi-anneau] $(S,(+,0),(*,1))$ is a set $S$ equipped with two binary operations $+$ (called *addition*) and $*$ (called *multiplication*) such that:

- $(S,+,0)$ is a commutative monoid

- $(S,*,1)$ is a monoid

- $0$ is the absorbing element for $*$

- and $*$ distributes over $+$.


**Definition 4.9** A *commutative semi-ring* is a semi-ring whose multiplication operation is commutative.

Note. The Boolean algebra with logical disjunction as addition and logical conjunction as multiplication is the smallest semi-ring that is not a ring.

**Definition 4.10** A *ring* is a semi-ring $(S,(+,0),(*,1))$ such that $(S,+,0)$ is a group, ie. every element has an inverse for $+$.

**Definition 4.11** A *field*  [fr-FR: corps] is a commutative ring where $0\neq 1$ and all non-zero elements are invertible under multiplication.
