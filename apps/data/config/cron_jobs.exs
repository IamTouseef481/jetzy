import Config

config :data, Jetzy.Support.Cron,
       jobs: [
#              legacy_sync: [
#                     schedule: "*/5 * * * *",
#                     task: {Jetzy.Support.Cron, :legacy_sync, []},
#                     run_strategy: Quantum.RunStrategy.Local
#              ],
       ]