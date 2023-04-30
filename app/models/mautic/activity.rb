module Mautic
  class Activity < Model
    class << self
      def endpoint
        'contacts/activity'
      end

      def field_name
        'events'
      end

      def all(connection, params = {})
        json = connection.request(:get, "api/#{endpoint}", params: params)
        json[field_name].map { |j| self.new(connection, j) }
      end

      def email_sent_all(connection, params = {})
        params[:filters][:includeEvents] = ['email.sent']
        all(connection, params)
      end
    end
  end
end