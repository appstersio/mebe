defmodule Mebe2.Web.Router do
  use Ace.HTTP.Service, port: 2142, cleartext: true
  use Raxx.Logger
  use Mebe2.Web.Middleware.RequestTime
  use Mebe2.Web.Middleware.Archives

  use Raxx.Router, [
    {%{method: :GET, path: ["tag", _tag, "p", _page]}, Mebe2.Web.Routes.Tag},
    {%{method: :GET, path: ["tag", _tag]}, Mebe2.Web.Routes.Tag},
    {%{method: :GET, path: ["archive", _year, _month, "p", _page]}, Mebe2.Web.Routes.Month},
    {%{method: :GET, path: ["archive", _year, _month]}, Mebe2.Web.Routes.Month},
    {%{method: :GET, path: ["archive", _year, "p", _page]}, Mebe2.Web.Routes.Year},
    {%{method: :GET, path: ["archive", _year]}, Mebe2.Web.Routes.Year},
    {%{method: :GET, path: ["p", _page]}, Mebe2.Web.Routes.Index},
    {%{method: :GET, path: [_year, _month, _day, _slug]}, Mebe2.Web.Routes.Post},
    {%{method: :GET, path: [_slug]}, Mebe2.Web.Routes.Page},
    {%{method: :GET, path: []}, Mebe2.Web.Routes.Index},
    {_, Mebe2.Web.Routes.NotFound}
  ]
end
