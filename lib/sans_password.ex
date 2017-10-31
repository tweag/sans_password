defmodule SansPassword do
  @moduledoc """
  A passwordless authentication system based on Guardian.
  """

  @login "login"
  @access "access"

  @callback resource_from_params(params :: map) :: {:ok, any} | {:error, atom}

  defmacro __using__(_) do
    quote do
      @behaviour SansPassword

      def encode_login(resource, claims \\ %{}) do
        SansPassword.encode_login(__MODULE__, resource, claims)
      end

      def decode_login(login_token, claims \\ %{}) do
        SansPassword.decode_login(__MODULE__, login_token, claims)
      end

      def encode_access(resource, claims \\ %{}) do
        SansPassword.encode_access(__MODULE__, resource, claims)
      end

      def decode_access(access_token, claims \\ %{}) do
        SansPassword.decode_access(__MODULE__, access_token, claims)
      end

      def exchange_login(login_token) do
        SansPassword.exchange_login(__MODULE__, login_token)
      end
    end
  end

  def encode_login(guardian, resource, claims \\ %{}) do
    guardian.encode_and_sign(resource, claims, token_type: @login)
  end

  def decode_login(guardian, login_token, claims \\ %{}) do
    guardian.resource_from_token(login_token, claims, token_type: @login)
  end

  def encode_access(guardian, resource, claims \\ %{}) do
    guardian.encode_and_sign(resource, claims, token_type: @access)
  end

  def decode_access(guardian, access_token, claims \\ %{}) do
    guardian.resource_from_token(access_token, claims, token_type: @access)
  end

  def exchange_login(guardian, login_token) do
    with {:ok, _, {token, claims}} <- guardian.exchange(login_token, @login, @access) do
      {:ok, token, claims}
    end
  end
end
