defmodule LeitnerWeb.Router do
  use LeitnerWeb, :router

  import LeitnerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LeitnerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug CORSPlug
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: LeitnerWeb.ApiSpec
  end

  scope "/" do
    pipe_through :browser

    live "/cards", LeitnerWeb.CardLive.Index, :index

    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    pipe_through :api
    get "/cards/quizz", LeitnerWeb.CardController, :quizz
    patch "/cards/:id/answer", LeitnerWeb.CardController, :answer
    resources "/cards", LeitnerWeb.CardController, except: [:new, :edit]

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:leitner, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authenticatioN
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LeitnerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LeitnerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LeitnerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LeitnerWeb do
    pipe_through [:browser, :require_authenticated_user]
    get "/", PageController, :home

    live "/cards/new", CardLive.Index, :new
    live "/cards/:id/edit", CardLive.Index, :edit

    live "/cards/:id", CardLive.Show, :show
    live "/cards/:id/show/edit", CardLive.Show, :edit

    live "/cards/:id/answer", CardLive.Index, :answer

    live_session :require_authenticated_user,
      on_mount: [{LeitnerWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LeitnerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LeitnerWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
