# Jetzy

# Select-MVP - Backend API 

* Make sure the Docker is Installed in your system, if not you can download it from here https://www.docker.com/.
* Pull postgres image for Database storage by running this command `docker run -d --name timescaledb -p 5432:5432 -e POSTGRES_PASSWORD=postgres timescale/timescaledb-ha:pg14-latest` once downloaded, start this image.
* You should have Elixir (V1.13.2) and NodeJS(V14.18.2) installed in your system.
* make a copy of `.env.template` as `.env` in the root directory
* and run `source .env` or just do `sh onebox` - this will export all the available environment (You may see some DB migration issues)
* make sure to create `/mnt/mnesia` directory in your system root directory or you can update your `.env` with custom directory by adding this `export JETZY_DEV_OVERRIDE_MNESIA_DIR="<CUSTOM_DIRECTORY_ABSOLUTE_PATH>"`
* Once the app is compiled successfully and when you see the `iex` session run the below commands
    * then go into the liquibase folder and make sure to update the config file `liquibase.properties.dev` (if not created, duplicate this `liquibase.properties`) with the proper DB credentials and then run `./update-schema`
    * Once liquibase is completed run `mix ecto.migrate`
    * Then run `sh onbox` and inside `iex` run `Mix.Tasks.Install.run` and then `Mix.Tasks.Migrate.run` so this will setup all the required Database for the API, so now you can run the API server in you local by login to `localhost:8080`
    * If in case youre stuck at `Mix.Tasks.Migrate.run` with the message `Elixir.Mix.Tasks.Install - Elixir.Noizu.MnesiaVersioning.Database.wait()` run the below commands 
        * `Amnesia.stop` 
        * `Amnesia.Schema.destroy` and then run the `Mix.Tasks.Install.run`

# Schema Configuration 
1. go to liquibase folder and run ./dev-update
2. run mix ecto.migrate 
3. drop into console and run Mix.Tasks.Migrate.run([])

For a full reset in console run  Amnesia.stop && Amnesia.Schema.destroy before repeating the above three strep. 
Ecto Migrate will attempt to configure your mnesia data directory for you, most likely under /mnt/mnesia/jetzy-dev


To start your Phoenix server:

  * Copy `.env` file to the project directory 
  * Run `make server`

