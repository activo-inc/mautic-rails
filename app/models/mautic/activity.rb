module Mautic
  class Activity < Model
    class << self
      def endpoint
        'contacts/activity'
      end

      def field_name
        'events' 
      end
    end
  end
end