defmodule Mebe2.Web.Router do
  use Ace.HTTP.Service, port: 2142, cleartext: true
  use Raxx.Logger
  use Mebe2.Web.Middleware.RequestTime
  use Mebe2.Web.Middleware.Archives
  alias Mebe2.Web.Routes

  use Raxx.Router, [
    {%{method: :GET, path: ["tag", _tag, "p", _page]}, Routes.Tag},
    {%{method: :GET, path: ["tag", _tag, "feed"]}, Routes.Tag},
    {%{method: :GET, path: ["tag", _tag]}, Routes.Tag},
    {%{method: :GET, path: ["archive", _year, _month, "p", _page]}, Routes.Month},
    {%{method: :GET, path: ["archive", _year, _month, "feed"]}, Routes.Month},
    {%{method: :GET, path: ["archive", _year, _month]}, Routes.Month},
    {%{method: :GET, path: ["archive", _year, "p", _page]}, Routes.Year},
    {%{method: :GET, path: ["archive", _year, "feed"]}, Routes.Year},
    {%{method: :GET, path: ["archive", _year]}, Routes.Year},
    {%{method: :GET, path: ["p", _page]}, Routes.Index},
    {%{method: :GET, path: ["feed"]}, Routes.Index},
    {%{method: :GET, path: [_year, _month, _day, _slug]}, Routes.Post},
    {%{method: :GET, path: [_slug]}, Routes.Page},
    {%{method: :GET, path: []}, Routes.Index},
    {_, Routes.NotFound}
  ]
end
