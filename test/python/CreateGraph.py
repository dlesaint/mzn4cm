import networkx as nx
import random
import os

def create_acyclic_graph(n, e):
    #if e >= n:
    #    raise ValueError("The number of edges must be less than the number of nodes to avoid cycles.")
    #if e < 0:
    #   raise ValueError("The number of edges must be non-negative.")
    
    G = nx.Graph()
    G.add_nodes_from(range(1, n + 1))
    
    edges = set()
    while len(edges) < e:
        u = random.randint(1, n-1)
        v = random.randint(u+1, n)
        if u != v and not (u,v) in edges:  # avoid creating a cycle
            G.add_edge(u, v)
            edges.add((u, v))
    
    return G

def create_cyclic_graph(n, e):
    G = nx.DiGraph()
    G.add_nodes_from(range(1, n + 1))

    edges = set()
    while len(edges) < e:
        u = random.randint(1, n)
        v = random.randint(1, n)
        if u != v and (u, v) not in edges:  # cycles are allowed, only avoid self-loops and duplicate arcs
            G.add_edge(u, v)
            edges.add((u, v))

    return G

def create_acyclyc_max_edge_graph(n):
    G = nx.Graph()
    G.add_nodes_from(range(1,n+1))
    edges = set()
    for i in range(1,n):
        for j in range(i+1,n+1):
            G.add_edge(i,j)
    return G

def generate_concept_names(n):
    return [f"concept_{i}" for i in range(1, n + 1)]

def generate_dzn_file(graph, concept_names, file_path):
    nodes = list(graph.nodes())
    edges = list(graph.edges())

    # Sort edges lexicographically
    edges = sorted(edges, key=lambda x: (x[0], x[1]))
    
    influences = ['-4', '-3',"-2","-1","1","2","3","4"]
    
    with open(file_path, 'w') as f:
        f.write('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        f.write('%%% INPUT C-MAP\n\n')
        f.write('icmap = (\n')
        f.write('    name:"generated_graph",\n')
        f.write('    itype: itype,\n')
        
        f.write('    node_labels:[\n')
        for node in nodes:
            f.write(f'        (node:{node}, concept:(name:"{concept_names[node-1]}")),\n')
        f.write('    ],\n')
        
        f.write('    arc_labels:[\n')
        for u, v in edges:
            influence = random.choice(influences)
            f.write(f'        (arc:(t:{u}, h:{v}), influence:(iblock:[{influence},4])),\n')
        f.write('    ],\n')
        f.write(');\n')

def create_batch(sizes, densities, repetitions, output_dir="."):
    os.makedirs(output_dir, exist_ok=True)

    for n in sizes:
        for density in densities:
            e = int(density * n * (n - 1))
            concept_names = generate_concept_names(n)

            acyclic_possible = e < n
            if not acyclic_possible:
                print(f"Densite {density} trop elevee pour n={n} (e={e} >= n={n}): graphe acyclique ignore.")

            for rep in range(1, repetitions + 1):
                if acyclic_possible:
                    acyclic_graph = create_acyclic_graph(n, e)
                    acyclic_path = os.path.join(output_dir, f"graph_n{n}_d{density}_acyclic_{rep}.dzn")
                    generate_dzn_file(acyclic_graph, concept_names, acyclic_path)

                cyclic_graph = create_cyclic_graph(n, e)
                cyclic_path = os.path.join(output_dir, f"graph_n{n}_d{density}_cyclic_{rep}.dzn")
                generate_dzn_file(cyclic_graph, concept_names, cyclic_path)


# Parameters
sizes = [10,20,50,100, 1000]
densities = [0.1, 0.2, 0.5, 0.9]
repetitions = 10
outputdir="test/test_cmaps"
create_batch(sizes, densities, repetitions, outputdir)
print(f"Graph .dzn file created at {outputdir}")
