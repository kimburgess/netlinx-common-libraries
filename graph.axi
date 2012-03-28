program_name='graph'
#if_not_defined __NCL_LIB_GRAPH
#define __NCL_LIB_GRAPH


define_constant
// Bounds for array sizes returned internally. These may be tweaked to optimise
// memory utilization.
GRAPH_MAX_NODES = 128
GRAPH_MAX_EDGES = 1024
GRAPH_MAX_ADJACENT_NODES = 16
GRAPH_MAX_HOPS = 8

// Internal constants
GRAPH_NULL_NODE_ID = 0
GRAPH_MAX_DISTANCE = $FFFF


define_type
structure graph_node {
	integer id
	char settled
	integer distance
	integer previous
}

structure graph_edge {
	integer id
	integer source
	integer destination
	integer weight
}

structure graph {
	integer nextNodeID
	integer nextEdgeID
	graph_node nodes[GRAPH_MAX_NODES]
	graph_edge edges[GRAPH_MAX_EDGES]
}


/**
 * Creates a new node in the passed graph.
 *
 * @param	g		the graph to create the node in
 * @return			an integer containing the node ID
 */
define_function integer graph_create_node(graph g)
{
	stack_var graph_node newNode
	g.nextNodeID++
	newNode.id = g.nextNodeID
	g.nodes[newNode.id] = newNode
	set_length_array(g.nodes, g.nextNodeID + 1)
	return newNode.id
}

/**
 * Defines a directed edge in the passed graph connecting the supplied edges.
 *
 * @param	g				the graph to create the edge in
 * @param	source			the node ID of the edge source
 * @param	desitination	the node ID of the edge desitination
 * @param	weight			the initial weighting to assign to the edge
 * @return					an integer containing the edge ID
 */
define_function integer graph_create_weighted_edge(graph g, integer source,
		integer destination, integer weight)
{
	stack_var graph_edge newEdge
	g.nextEdgeID++
	newEdge.id = g.nextEdgeID
	newEdge.source = source
	newEdge.destination = destination
	newEdge.weight = weight
	g.edges[newEdge.id] = newEdge
	set_length_array(g.edges, g.nextEdgeID + 1)
	return newEdge.id
}

/**
 * Defines a directed edge in the passed graph connecting the supplied edges
 * with a default weighting.
 *
 * @param	g			the graph to create the edge in
 * @param	source		the node ID of the edge source
 * @param	destination	the node ID of the edge desitination
 * @return				an integer containing the edge ID
 */
define_function integer graph_create_edge(graph g, integer source,
		integer destination)
{
	return graph_create_weighted_edge(g, source, destination, 1)
}

/**
 * Finds the closest unsettled node in the passed graph.
 *
 * @param	g		the graph to search
 * @return			an integer containg the closest unsettled node ID
 */
define_function integer graph_get_closest_unsettled_node(graph g) {
	stack_var integer i
	stack_var graph_node n
	stack_var graph_node closest

	closest.distance = GRAPH_MAX_DISTANCE

	for (i = 1; i <= length_array(g.nodes); i++) {
		n = g.nodes[i]
		if (n.settled == false && (n.distance < closest.distance)) {
			closest = n
		}
	}

	return closest.id
}

/**
 * Finds the unsettled neighbours of the passed node.
 *
 * @param	g		the graph to search
 * @param	node	the node ID of the node of interest
 * @return			an array containing the node ID's of adjacent unsettled
 *					nodes
 */
define_function integer[GRAPH_MAX_ADJACENT_NODES] graph_get_neighbors(graph g,
		integer node)
{
	stack_var integer i
	stack_var integer j
	stack_var integer neighbors[GRAPH_MAX_ADJACENT_NODES]
	stack_var graph_edge e

	for (i = length_array(g.edges); i > 0; i--) {
		e = g.edges[i]
		if (e.destination != GRAPH_NULL_NODE_ID) {
			if (e.source == node && g.nodes[e.destination].settled == false) {
				j++
				neighbors[j] = e.destination
			}
		}
	}

	set_length_array(neighbors, j)
	return neighbors
}

/**
 * Finds the distance (/weight) of the edge connecting the passed nodes.
 *
 * @param	g			the graph to search
 * @param	source		the edge source node ID
 * @param	destination	the edge destination node ID
 * @return				the weight of the joining edge
 */
define_function integer graph_get_distance(graph g, integer source,
		integer destination)
{
	stack_var integer i
	stack_var graph_edge e

	for (i = 1; i <= length_array(g.edges); i++) {
		e = g.edges[i]
		if (e.source == source && e.destination == destination) {
			return e.weight
		}
	}

	return GRAPH_MAX_DISTANCE
}

/**
 * Traverse the passed graph and compute all paths from the passed source node.
 *
 * This uses an implementation of Dijkstra's algorithm. After traversal paths
 * are cached within the graph.
 *
 * @param	g		the graph to traverse
 * @param	source	the node ID of the source to calculate paths from
 */
define_function graph_compute_paths(graph g, integer source)
{
	stack_var integer i
	stack_var integer n
	stack_var integer altDist

	for (i = length_array(g.nodes); i > 0; i--) {
		g.nodes[i].settled = false
		g.nodes[i].distance = GRAPH_MAX_DISTANCE
		g.nodes[i].previous = GRAPH_NULL_NODE_ID
	}

	g.nodes[source].distance = 0

	while (true) {
		stack_var integer adjacentNodes[GRAPH_MAX_ADJACENT_NODES]

		n = graph_get_closest_unsettled_node(g)
		if (n == GRAPH_NULL_NODE_ID) break
		if (g.nodes[n].distance == GRAPH_MAX_DISTANCE) break

		g.nodes[n].settled = true

		adjacentNodes = graph_get_neighbors(g, n)

		for (i = 1; i <= length_array(adjacentNodes); i++) {
			if (adjacentNodes[i] == GRAPH_NULL_NODE_ID) break

			altDist = g.nodes[n].distance+ graph_get_distance(g, n,
					adjacentNodes[i])
			if (g.nodes[adjacentNodes[i]].distance > altDist) {
				g.nodes[adjacentNodes[i]].distance = altDist
				g.nodes[adjacentNodes[i]].previous = n
				g.nodes[adjacentNodes[i]].settled = false
			}
		}
	}
}

/**
 * Find the optimum path to the passed destination node based on a previously
 * computed graph.
 *
 * @param	g			a previously computed (using graph_compute_paths())
 *						graph
 * @param	destination	the ID of the destination node to find the path to
 * @return				an array containing the nodes that form the optimum path
 *						to the destination node
 */
define_function integer[GRAPH_MAX_HOPS] graph_get_shortest_path(graph g,
		integer destination)
{
	stack_var integer path[GRAPH_MAX_HOPS]
	stack_var integer step
	stack_var integer hop

	step = destination
	hop++
	path[hop] = step

	while (g.nodes[step].previous != GRAPH_NULL_NODE_ID) {
		step = g.nodes[step].previous
		hop++
		path[hop] = step
	}

	set_length_array(path, hop)
	return path
}

#end_if