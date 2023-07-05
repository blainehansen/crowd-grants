PGPASSWORD='asdf' psql database -U user -h localhost -f dev.sql | cat

# # cargo test --package persistent_democracy_core
# cargo test --package persistent_democracy_core test_constitution_tree_from_vec -- --show-output
