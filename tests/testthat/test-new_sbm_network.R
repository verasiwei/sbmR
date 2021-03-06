test_that("Correct numbers of nodes and edges are returned", {
  network <- sim_basic_block_network(
    n_blocks = 3,
    n_nodes_per_block = 40,
    random_seed = 42
  )


  expect_equal(attr(network, "n_nodes"), 3*40)
  expect_equal(attr(network, "n_edges"), nrow(network$edges))
})


test_that("Properly builds a missing nodes dataframe",{
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1",  "b1",
    "a1",  "b2",
    "a1",  "b3",
    "a2",  "b1",
    "a2",  "b4",
    "a3",  "b1"
  )

  sbm_net <- new_sbm_network(edges = edges, random_seed = 42)

  expect_equal(
    sbm_net$nodes,
    dplyr::tribble(
      ~id, ~type,
      "a1", "node",
      "a2", "node",
      "a3", "node",
      "b1", "node",
      "b2", "node",
      "b3", "node",
      "b4", "node"
    )
  )
})


test_that("Throws error for poorly formed nodes dataframe",{
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "a2"   , "b4"   ,
    "a3"   , "b1"
  )

  nodes <- dplyr::tribble(
    ~name, ~type,
    "a1", "node",
    "a2", "node",
    "a3", "node",
    "b1", "node",
    "b2", "node",
    "b3", "node",
    "b4", "node"
  )

  expect_error(
    new_sbm_network(edges = edges,
                    nodes = nodes,
                    random_seed = 42),
    "Nodes dataframe needs an id column.",
    fixed = TRUE
  )

})


test_that("Throws error for empty edges dataframe",{
  edges <- dplyr::tribble(
    ~from, ~to
  )

  nodes <- dplyr::tribble(
    ~id, ~type,
    "a1", "node",
    "a2", "node",
    "a3", "node",
    "b1", "node",
    "b2", "node",
    "b3", "node",
    "b4", "node"
  )

  expect_error(
    new_sbm_network(edges = edges,
                    nodes = nodes,
                    random_seed = 42),
    "No edges provided",
    fixed = TRUE
  )
})


test_that("Throws error for edges dataframe missing required columns",{
  edges <- dplyr::tribble(
    ~a_node, ~b_node,
    "a1",  "b1",
    "a1",  "b2",
    "a1",  "b3",
    "a2",  "b1",
    "a2",  "b4",
    "a3",  "b1"
  )

  expect_error(
    new_sbm_network(edges = edges,
                    edges_from_column = a_node,
                    edges_to_column = node_b,
                    random_seed = 42),
    "Edges data does not have the specified to column: node_b",
    fixed = TRUE
  )

  expect_error(
    new_sbm_network(edges = edges,
                    edges_from_column = node_a,
                    edges_to_column = b_node,
                    random_seed = 42),
    "Edges data does not have the specified from column: node_a",
    fixed = TRUE
  )
})


test_that("Throws warning for discarded unconnected nodes",{
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "a2"   , "b4"   ,
    "a3"   , "b1"
  )

  nodes <- dplyr::tribble(
    ~id, ~type,
    "a1", "node",
    "a2", "node",
    "a3", "node",
    "b1", "node",
    "b2", "node",
    "b3", "node",
    "b4", "node",
    "c1", "node",
    "c2", "node"
  )

  expect_warning(
    new_sbm_network(edges = edges,
                    nodes = nodes,
                    show_warnings = TRUE,
                    random_seed = 42),
    "Node(s) c1, c2 are not seen in any of the edges and have been removed from data.",
    fixed = TRUE
  )

})


test_that("Throws warning for overridden bipartite_edges argument",{
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "a2"   , "b4"   ,
    "a3"   , "b1"
  )

  nodes <- dplyr::tribble(
    ~id, ~type,
    "a1", "node",
    "a2", "node",
    "a3", "node",
    "b1", "node",
    "b2", "node",
    "b3", "node",
    "b4", "node"
  )

  expect_warning(
    new_sbm_network(edges = edges,
                    nodes = nodes,
                    bipartite_edges = TRUE,
                    show_warnings = TRUE,
                    random_seed = 42),
    "bipartite_edges setting ignored due to nodes dataframe being provided.",
    fixed = TRUE
  )

})


test_that("Throws messages for mismatched bipartite edges and nodes", {
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "b1"   , "b4"   ,
    "a3"   , "b1"
  )

  expect_error(
    new_sbm_network(edges = edges,
                    bipartite_edges = TRUE,
                    random_seed = 42),
    "Bipartite edge structure was requested but some nodes appeared in both from and two columns of supplied edges.",
    fixed = TRUE
  )
})


test_that("Bipartite node structure respects the column names in types", {
  edges <- dplyr::tribble(
    ~a_node, ~b_node,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "a3"   , "b1"
  )

  sbm_net <- new_sbm_network(edges = edges,
                             bipartite_edges = TRUE,
                             edges_from_col = a_node,
                             edges_to_col = b_node,
                             random_seed = 42)

  unique_types <- unique(sbm_net$nodes$type)
  expect_true(all(unique_types %in% c('a_node', 'b_node')))
})


test_that("Default node type can change", {
  edges <- dplyr::tribble(
    ~from, ~to,
    "a1"   , "b1"   ,
    "a1"   , "b2"   ,
    "a1"   , "b3"   ,
    "a2"   , "b1"   ,
    "b1"   , "b4"   ,
    "a3"   , "b1"
  )

  expect_equal(
    new_sbm_network(edges = edges,
                    default_node_type = "my_node_type",
                    random_seed = 42)$nodes$type[1],
    "my_node_type")
})


test_that("Model is instantiated if requested", {
  network <- sim_basic_block_network(
    n_blocks = 3,
    n_nodes_per_block = 40,
    setup_model = TRUE,
    random_seed = 42
  )

  testthat::expect_false(is.null(attr(network, 'model')))
})


test_that("Model is not instantiated by default", {
  network <- sim_basic_block_network(
    n_blocks = 3,
    n_nodes_per_block = 40,
    random_seed = 42
  )

  testthat::expect_true(is.null(attr(network, 'model')))
})


