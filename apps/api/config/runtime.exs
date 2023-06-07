import Config

config :logger, :console,
  format: "NODE [$level] $message $metadata\n"
