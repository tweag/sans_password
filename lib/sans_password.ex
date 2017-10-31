defmodule SansPassword do
  @moduledoc """
  Passwordless authentication helpers for Guardian.
  """

  @magic "magic"
  @access "access"

  @callback deliver_magic_link(resource :: any, magic_token :: String.t) :: any

  defmacro __using__(_) do
    quote do
      @behaviour SansPassword

      def encode_magic(resource, claims \\ %{}) do
        SansPassword.encode_magic(__MODULE__, resource, claims)
      end

      def decode_magic(magic_token, claims \\ %{}) do
        SansPassword.decode_magic(__MODULE__, magic_token, claims)
      end

      def encode_access(resource, claims \\ %{}) do
        SansPassword.encode_access(__MODULE__, resource, claims)
      end

      def decode_access(access_token, claims \\ %{}) do
        SansPassword.decode_access(__MODULE__, access_token, claims)
      end

      def exchange_magic(magic_token) do
        SansPassword.exchange_magic(__MODULE__, magic_token)
      end

      def send_magic_link(resource, claims \\ %{}) do
        SansPassword.send_magic_link(__MODULE__, resource, claims)
      end
    end
  end

  def encode_magic(guardian, resource, claims \\ %{}) do
    guardian.encode_and_sign(resource, claims, token_type: @magic)
  end

  def decode_magic(guardian, magic_token, claims \\ %{}) do
    guardian.resource_from_token(magic_token, claims, token_type: @magic)
  end

  def encode_access(guardian, resource, claims \\ %{}) do
    guardian.encode_and_sign(resource, claims, token_type: @access)
  end

  def decode_access(guardian, access_token, claims \\ %{}) do
    guardian.resource_from_token(access_token, claims, token_type: @access)
  end

  def exchange_magic(guardian, magic_token) do
    with {:ok, _, {token, claims}} <- guardian.exchange(magic_token, @magic, @access) do
      {:ok, token, claims}
    end
  end

  def send_magic_link(guardian, resource, claims \\ %{}) do
    with {:ok, magic_token, claims} <- guardian.encode_magic(resource, claims) do
      guardian.deliver_magic_link(resource, magic_token)
      {:ok, magic_token, claims}
    end
  end
end
