# docker-db-preloader

Tool to create prefilled database docker containers with jenkins and docker-compose.

Use case: Speed up CI/CD pipelines or dev environment setups immensely by importing your data only once and saving the preloaded database container to your private registry. Reset your database state almost instantly between tests.

##Concept
- build and start mysql or mariadb container
- using the docker-entrypoint, supplied sql files are executed and data imported
- in a testing step, database content is compared between directly-after-import and from-preloaded-container stages
- resulting data container (/var/lib/mysql content) can be pushed to registry

##Example Usage:
1) Create new jenkins project with this repository as source
2) Copy pipeline config from ``Jenkinsfile.dist``
3) Adapt sql path, base and target image settings in stage "setting Dotenv config"
4) Adapt database validation steps

##Example .env:
- see .env.dist
- also check related base image docs:
    - https://hub.docker.com/_/mysql/
    - https://hub.docker.com/_/mariadb/
```
# base image settings
DATABASE_ROOT_PASSWORD=root
#DATABASE_USER=test
#DATABASE_PASSWORD=test
#DATABASE_NAME=test

# docker-db-preloader settings
IMPORT_TIMEOUT_SECONDS=0
BASE_IMAGE=mysql:5.6
SQL_PATH_VOLUME=./examples/01-simple/sql
TARGET_IMAGE=registry.deubert.it:5000/db-databuilder/db-preloaded-01
```

This example configuration will build a new container based on mysql 5.6, import all files from `./examples/01-simple/sql` and then push the preloaded db container to `registry.deubert.it:5000/db-databuilder/db-preloaded-01`.  

##Todo
- Improve configuration and (re-)usability
- Move hardcoded testing configuration from Jenkinsfile to ENV config
- Add more testcases
- Proper permission handling, especially in failure scenarios (data directory permissions will change when consumed as volume by docker)
- IMPORT_TIMEOUT_SECONDS has no effect yet, but setting to 0 will not break your import
