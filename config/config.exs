# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :mebe_2, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:mebe_2, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :mebe_2,
  # The path to crawl post and page data from. No trailing slash, use an absolute path.
  data_path: Path.expand("data"),

  # Port to listen on
  port: 2124,
  # Basic blog information
  blog_name: "My awesome blog",
  blog_author: "Author McAuthor",
  blog_description: "Description for SEO.",
  # Twitter username of blog author (without @) or nil for none
  blog_author_twitter: nil,
  # Absolute URL to the site, including protocol, no trailing slash
  absolute_url: "http://localhost:2124",
  # Default timezone to use for posts with time data
  time_default_tz: "Europe/Helsinki",
  # Force "Read more…" text to display even if there is no more content
  force_read_more: false,
  # Set to true to enable RSS feeds
  enable_feeds: false,
  # Show full content in feeds instead of short content
  feeds_full_content: false,
  posts_per_page: 10,
  posts_in_feed: 20,

  # Disqus comments
  # Use Disqus comments
  disqus_comments: false,
  # Show comments for pages too
  page_commenting: false,
  disqus_shortname: "my-awesome-blog",

  # Extra HTML that is injected to every page, right before </body>. Useful for analytics scripts.
  extra_html: """
  <script>
    window.tilastokeskus_url = '/tilastokeskus/track';
  </script>
  <script src="/tilastokeskus/track.js" async></script>
  """

if Mix.env() == :dev do
  config :exsync, :extensions, [".ex", ".eex"]
end

if Mix.env() == :prod do
  config :logger,
    level: :error,
    compile_time_purge_matching: [
      [level_lower_than: :error]
    ]
end

# If you wish to compile in secret settings, use the following file. Note that the settings in
# the file will be set at release generation time and cannot be changed later.
if File.exists?("config/config.secret.exs") do
  import_config("config.secret.exs")
end
