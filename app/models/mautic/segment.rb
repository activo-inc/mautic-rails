module Mautic
  class Segment < Model

    def add_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request(:post, "api/segments/#{id}/contact/#{contact_id}/add")
    end

    def remove_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request(:post, "api/segments/#{id}/contact/#{contact_id}/remove")
    end

    def self.add_contact(connection: nil, segment: nil, contact: nil)
      return if segment.blank? || contact.blank?
      segment = segment.is_a?(self) ? segment : self.find(connection, segment)
      segment.add_contact contact
    end

    def self.remove_contact(connection: nil, segment: nil, contact: nil)
      return if segment.blank? || contact.blank?
      segment = segment.is_a?(self) ? segment : self.find(connection, segment)
      segment.remove_contact contact
    end

  end
end