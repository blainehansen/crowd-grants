PG_URL='postgres://user:asdf@localhost:5432/database?sslmode=disable'
docker run --rm -it --network host -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):/working -e PG_URL=$PG_URL blainehansen/postgres_migrator "$@"

# generate 'migration message'
# migrate
