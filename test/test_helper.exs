Mix.Task.run "ecto.drop", ["--quiet", "-r", "Passwordless.TestRepo"]
Mix.Task.run "ecto.create", ["--quiet", "-r", "Passwordless.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "Passwordless.TestRepo"]

{:ok, _} = Passwordless.TestRepo.start_link

ExUnit.start()
