defmodule SansPassword.SerializerTest do
  use SansPassword.Case

  alias SansPassword.{Invite, Serializer, TestUser, TestRepo}

  describe "for_token/1" do
    test "with a user" do
      result = Serializer.for_token(%TestUser{id: 1})
      assert {:ok, "User:1"} == result
    end

    test "with an invite" do
      result = Serializer.for_token(%Invite{email: "user@example.com"})
      assert {:ok, "Invite:user@example.com"} = result
    end

    test "when invalid" do
      result = Serializer.for_token(nil)
      assert {:error, _} = result
    end
  end

  describe "from_token/1" do
    setup do
      [user: TestRepo.insert!(%TestUser{email: "user@example.com"})]
    end

    test "with a user", %{user: %{id: id}} do
      assert {:ok, %TestUser{id: ^id}} = Serializer.from_token("User:#{id}")
    end

    test "with a non-existent user" do
      assert {:error, _} = Serializer.from_token("User:999")
    end

    test "with an invite" do
      assert {:ok, "user@example.com"} = Serializer.from_token("Invite:user@example.com")
    end

    test "when invalid" do
      assert {:error, _} = Serializer.from_token(nil)
    end
  end
end
