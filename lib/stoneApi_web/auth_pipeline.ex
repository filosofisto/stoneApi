defmodule StoneApi.Guardian.AuthPipeline do
    use Guardian.Plug.Pipeline, otp_app: :StoneApi,
    module: StoneApi.Guardian,
    error_handler: StoneApi.AuthErrorHandler
  
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end
