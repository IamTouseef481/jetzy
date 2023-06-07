DO NO USE
=================================

Except for initiating Oban tables or tables of any other deps that requires it do not use Ecto Migrations for schema management.
Use  %project_root%/liquibase  

For more information see: (https://docs.liquibase.com/home.html)

You should be able to run ./dev-update from your build environment to apply change sets. 
On the initial change set run you may want to manually mark tables as imported already or drop and recreate your postgres table. 