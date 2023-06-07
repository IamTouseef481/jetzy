#!make
include .env
.PHONY: help console outdated setup local_server live_server test test-clear update-mix check iex

HELP_PADDING = 20

help: ## Shows this help.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
			IFS=$$'#' ; \
			help_split=($$help_line) ; \
			help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			printf "%-$(HELP_PADDING)s %s\n" $$help_command $$help_info ; \
	done

.env:
	cp .env

console: ## Opens the App console.
	iex -S mix

outdated: ## Shows outdated packages.
	mix hex.outdated

assets/node_modules: assets/package-lock.json
	npm install --prefix=assets

deps:
	mix.lock

local_server:
	mix deps.get
	echo export
	mix compile
	mix ecto.migrate
	mix phx.swagger.generate
	iex -S mix phx.server


stage-swagger:
	MIX_ENV=stage mix phx.swagger.generate

prod-swagger:
	MIX_ENV=prod mix phx.swagger.generate

preprod-swagger:
	MIX_ENV=preprod mix phx.swagger.generate

stage_server:
	git pull
	MIX_ENV=stage mix deps.get
	MIX_ENV=stage mix distillery.release --upgrade --env=stage
	rsync -avz --ignore-existing _build/stage/rel/jetzy/releases/ stage-dist/releases/

preprod_server:
	git pull
	MIX_ENV=preprod mix deps.get
	MIX_ENV=preprod mix distillery.release --upgrade --env=preprod
	rsync -avz --ignore-existing _build/preprod/rel/jetzy/releases/ preprod-dist/releases/

prod_server:
	git pull
	MIX_ENV=prod mix deps.get
	MIX_ENV=prod mix distillery.release --upgrade --env=prod
	rsync -avz --ignore-existing _build/prod/rel/jetzy/releases/ prod-dist/releases/



update-mix: ## Update mix packages.
	mix deps.update --all

rollback:
	mix ecto.rollback && MIX_ENV=test mix ecto.rollback

migrate:
	mix ecto.migrate && MIX_ENV=test mix ecto.migrate

stage_migrate:
	MIX_ENV=stage elixir --name $(JETZY_STAGE_API_NODE_NAME)  --cookie "cHJQc;SdIMU$fZE8ZFg;r%J^TtK1FrvH=L)uwR7DS{7]OhnvbBrFCm:qa>?R{jvs" -S mix ecto.migrate

preprod_migrate:
	MIX_ENV=preprod elixir --name $(JETZY_PREPROD_API_NODE_NAME)  --cookie "cHJQc;SdIMU$fZE8ZFg;r%J^TtK1FrvH=L)uwR7DS{7]OhnvbBrFCm:qa>?R{jvs" -S mix ecto.migrate

prod_migrate:
	MIX_ENV=prod elixir --name $(JETZY_PROD_API_NODE_NAME)  --cookie "cHJQc;SdIMU$fZE8ZFg;r%J^TtK1FrvH=L)uwR7DS{7]OhnvbBrFCm:qa>?R{jvs" -S mix ecto.migrate


check:
	mix format
	MIX_ENV=test mix credo
	mix dialyzer

iex: setup
	iex -S mix phx.server
