# db-databuilder

Tools to create prefilled database volume containers.

Concept:
- build and start mysql or mariadb container
- using the docker-entrypoint, supplied sql files are executed
- resulting data container (/var/lib/mysql content) can be pushed to registry