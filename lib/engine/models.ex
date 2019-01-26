defmodule Mebe2.Engine.Models do
  @moduledoc """
  This module contains the data models of the blog engine.
  """

  defmodule PageData do
    defstruct filename: "",
              title: "",
              headers: [],
              content: ""

    @type t :: %__MODULE__{
            filename: String.t(),
            title: String.t(),
            headers: [{String.t(), String.t()}],
            content: String.t()
          }
  end

  defmodule Post do
    defstruct slug: nil,
              title: nil,
              datetime: nil,
              time_given: false,
              tags: [],
              content: nil,
              short_content: nil,
              order: 0,
              has_more: false,
              extra_headers: %{}

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t(),
            datetime: DateTime.t(),
            time_given: boolean,
            tags: [String.t()],
            content: String.t(),
            short_content: String.t(),
            order: integer,
            has_more: boolean,
            extra_headers: %{optional(String.t()) => String.t()}
          }
  end

  defmodule Page do
    defstruct slug: nil,
              title: nil,
              content: nil,
              extra_headers: %{}

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t(),
            content: String.t(),
            extra_headers: %{optional(String.t()) => String.t()}
          }
  end

  defmodule MenuItem do
    defstruct slug: nil,
              title: nil

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t()
          }
  end
end
