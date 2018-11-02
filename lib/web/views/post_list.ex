defmodule Mebe2.Web.Views.PostList do
  use Raxx.View,
    template: "post_list.html.eex",
    arguments: [:posts, :total, :page, :path_generator]
end
