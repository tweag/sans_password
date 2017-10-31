Mix.Tasks.Ecto.Drop.run(["-r", "SansPassword.Dummy.Repo"])
Mix.Tasks.Ecto.Create.run(["-r", "SansPassword.Dummy.Repo"])
Mix.Tasks.Ecto.Migrate.run(["-r", "SansPassword.Dummy.Repo"])

ExUnit.start()
