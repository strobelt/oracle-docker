# Oracle 12c Docker Official Image with Custom Scripts
This project is a simple customization for the Oracle 12c official Docker image available [here](https://hub.docker.com/_/oracle-database-enterprise-edition).

Basically *setupDB.sh* is a script taken from inside the oracle container and customized to call another bash script (*runInitialScripts.sh*) that runs every sql file present on the mounted volume folder.

It is important to note that the scripts will be applied sequentially in alphabetical order, so name them accordingly if execution order matters. E.g. 01-DatabaseConfig.sql, 02-InitialSchemas.sql, 03-Seed.sql, etc.
Also it is important to note that every file that does not have the *.sql* extension will be ignored

## Usage
1. Add your custom sql scripts to the volume folder (it will be mounted when we execute the docker container)
2. Login to the [docker portal](https://hub.docker.com/)
3. Acquire Oracle image from the [store](https://hub.docker.com/_/oracle-database-enterprise-edition)
4. Install Docker for your OS [Windows](https://docs.docker.com/docker-for-windows/install/) | [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/) | [MacOS](https://docs.docker.com/docker-for-mac/install/)
5. Run `docker login` to authenticate with your Docker account
6. Run the cake task **SetupAndWaitContainer**:
    ```bash
    ./build.sh -t SetupAndWaitContainer
    ```
    or
    ```
    .\build.ps1 -t SetupAndWaitContainer
    ```

## Connection
- Hostname: localhost
- Port: 1521
- Service Name: ORCLCDB.localdomain
- User: sys
- Password: Oradoc_db1

## Documentation
- [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/index.html)
- [Good tutorial that helped with this solution](https://technology.amis.nl/2017/11/18/run-oracle-database-in-docker-using-prebaked-image-from-oracle-container-registry-a-two-minute-guide/)
