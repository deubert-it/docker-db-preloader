# db-databuilder

Tools to create prefilled database volume containers with jenkins and docker-compose.

Concept:
- build and start mysql or mariadb container
- using the docker-entrypoint, supplied sql files are executed and data imported
- resulting data container (/var/lib/mysql content) can be pushed to registry