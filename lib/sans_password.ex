defmodule SansPassword do
  @moduledoc """
  A passwordless authentication system based on Guardian.
  """

  defmacro __using__(_) do
    quote do
      @login "login"
      @access "access"

      def encode_login(resource, claims \\ %{}) do
        encode_and_sign(resource, claims, token_type: @login)
      end

      def decode_login(login_token, claims \\ %{}) do
        resource_from_token(login_token, claims, token_type: @login)
      end

      def encode_access(resource, claims \\ %{}) do
        encode_and_sign(resource, claims, token_type: @access)
      end

      def decode_access(access_token, claims \\ %{}) do
        resource_from_token(access_token, claims, token_type: @access)
      end

      def exchange_login(login_token) do
        with {:ok, _, {token, claims}} <- exchange(login_token, @login, @access) do
          {:ok, token, claims}
        end
      end
    end
  end
end
