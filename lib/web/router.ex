defmodule Mebe2.Web.Router do
  use Ace.HTTP.Service, port: 2142, cleartext: true
  use Raxx.Logger
  use Mebe2.Web.Middleware.RequestTime

  use Raxx.Router, [
    {%{method: :GET, path: [_year, _month, _day, _slug]}, Mebe2.Web.Routes.Post},
    {%{method: :GET, path: [_slug]}, Mebe2.Web.Routes.Page},
    {%{method: :GET, path: []}, Mebe2.Web.Routes.Index},
    {_, Mebe2.Web.Routes.NotFound}
  ]
end
