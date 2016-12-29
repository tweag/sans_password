Mix.Task.run "ecto.drop", ["--quiet", "-r", "SansPassword.TestRepo"]
Mix.Task.run "ecto.create", ["--quiet", "-r", "SansPassword.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "SansPassword.TestRepo"]

{:ok, _} = SansPassword.TestRepo.start_link

ExUnit.start()
