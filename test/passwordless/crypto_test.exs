defmodule Passwordless.CryptoTest do
  use ExUnit.Case
  import Passwordless.Crypto

  describe "hmac/1" do
    test "encodes a value" do
      assert hmac("foo") == "LUT_WT0SIKioR9iBNhonmHM6G7ow3thdNIBTl1ReoGE"
    end
  end

  describe "valid_hmac?/2" do
    test "accepts equality" do
      assert valid_hmac?(hmac("foo"), from: "foo")
    end

    test "rejects inequality" do
      refute valid_hmac?("foo", from: "foo")
    end
  end

  describe "generate_token/1" do
    test "generates a random string" do
      assert String.length(generate_token()) == 86
    end
  end
end
