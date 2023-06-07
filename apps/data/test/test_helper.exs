{:ok, _} = Application.ensure_all_started(:semaphore)

Application.load(:tzdata)
{:ok, _} = Application.ensure_all_started(:tzdata)

# Schema Setup
Amnesia.Schema.create()

# Start Amnesia
Amnesia.start()

ExUnit.start()