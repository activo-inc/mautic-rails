module Mautic
  module Connections
    class Oauth2 < Mautic::Connection

      def client
        @client ||= OAuth2::Client.new(client_id, secret, {
          site: url,
          authorize_url: 'oauth/v2/authorize',
          token_url: 'oauth/v2/token',
          raise_errors: false,
          # NOTE: oauth2 2.0 で :auth_scheme の既定が :request_body から :basic_auth に変わった。
          #       Mautic のトークンエンドポイントに対する認証方式を 1.4.x 時点の挙動のまま保つため
          #       :request_body を明示する（client_id / secret をリクエストボディで送る）。
          auth_scheme: :request_body
        })
      end

      def authorize(context)
        client.auth_code.authorize_url(redirect_uri: callback_url(context))
      end

      def get_code(code, context)
        client.auth_code.get_token(code, redirect_uri: callback_url(context))
      end

      def connection
        @connection ||= OAuth2::AccessToken.new(client, token, { refresh_token: refresh_token })
      end

      def refresh!
        @connection = connection.refresh!
        update(token: @connection.token, refresh_token: @connection.refresh_token)
        @connection
      rescue StandardError
        raise ::Mautic::TokenExpiredError, "your refresh_token is probably expired - re-authorize your connection"
      end

      def request(type, path, params = {})
        @last_request = [type, path, params]
        response = connection.request(type, path, params)
        parse_response(response)
      end

      private

      def callback_url(context)
        uri = super
        # uri.path = Mautic::Engine.routes.url_helpers.oauth2_connection_path(self)
        uri.path = context.url_for(action: "oauth2", id: self , only_path: true)
        uri.to_s
      end

    end
  end
end
