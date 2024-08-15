module Mautic
  class Campaign < Model

    def self.list_campaign_contacts(connection:, campaign:)
      contacts = connection.request :get, %(api/campaigns/#{campaign}/contacts)
      contacts["contacts"]
    end

    # @see https://developer.mautic.org/#add-contact-to-a-campaign
    # @param [Integer] id of Mautic::Contact
    def add_contact!(id)
      json = @connection.request(:post, "api/campaigns/#{self.id}/contact/#{id}/add")
      json["success"]
    rescue RequestError => _e
      false
    end

    # @see https://developer.mautic.org/#remove-contact-from-a-campaign
    # @param [Integer] id of Mautic::Contact
    def remove_contact!(id)
      json = @connection.request(:post, "api/campaigns/#{self.id}/contact/#{id}/remove")
      json["success"]
    rescue RequestError => _e
      false
    end
  end
end
