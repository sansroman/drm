defmodule DrmTest do
  use ExUnit.Case
  doctest Drm

  import Drm.CLI, only: [parse_args: 1, sort_tags: 1]

  test ":help returned by option pasing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == %{command: :help}
    assert parse_args(["--help", "anything"]) == %{command: :help}
    assert parse_args(["-v", "anything"]) == %{command: :version}
    assert parse_args(["--version", "anything"]) == %{command: :version}
  end

  test "return command if command given" do
    assert parse_args(["images"]) == %{command: :images}
  end

  test "return help if no value given" do
    assert parse_args([]) == %{command: :help}
  end

  test "return command and params if params given" do
    assert parse_args(["container", "ls"]) == %{command: :container, params: ["ls"]}
  end

  test "sort tags order the correct way" do
    fake_tags_at_list = ["0.0.4", "0.0.5", "0.1.3",  "latest", "0.0.1"]
    result = sort_tags(fake_tags_at_list)

    assert result == ["latest", "0.1.3", "0.0.5", "0.0.4", "0.0.1"]
  end
end
