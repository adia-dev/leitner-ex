defmodule LeitnerWeb.ApiSpec do
  alias OpenApiSpex.SecurityScheme
  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server}
  alias LeitnerWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "LeitnerApi",
        version: "1.0"
      },
      paths: Paths.from_router(Router),
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
