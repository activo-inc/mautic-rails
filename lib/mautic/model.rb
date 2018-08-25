module Mautic
  class Model < OpenStruct

    class MauticHash < Hash

      def []=(name, value)
        @changes ||= {}
        @changes[name] = value
        super
      end

      def changes
        @changes || {}
      end

    end

    class Attribute < OpenStruct

      def name
        @alias
      end

    end

    class << self

      def endpoint
        field_name
      end

      def field_name
        name.demodulize.underscore.pluralize
      end

      def in(connection)
        Proxy.new(connection, endpoint)
      end

      def all(connection, params = {})
        json = connection.request(:get, "api/#{endpoint}", params: params)
        json[field_name].map { |_, j| self.new(connection, j) }
      end

      def create(connection, params = {})
        begin
          json = connection.request(:post, "api/#{endpoint}/new", body: params)
          instance = new(connection, json[field_name.singularize])
        rescue ValidationError => e
          if instance.nil?
            raise e
          else
            instance.errors = e.errors
          end
        end

        instance
      end

      def find(connection, id, params = {})
        begin
          json = connection.request(:get, "api/#{endpoint}/#{id}", params: params)
          instance = new(connection, json[field_name.singularize])
        rescue ValidationError => e
          if instance.nil?
            raise e
          else
            instance.errors = e.errors
          end
        end

        instance
      end

    end

    def initialize(connection, hash=nil)
      @connection = connection
      @table = MauticHash.new
      self.attributes = { id: hash['id'], created_at: hash['dateAdded']&.to_time, updated_at: hash['dateModified']&.to_time } if hash
      assign_attributes(hash)
      clear_changes
    end

    def save(force = false)
      id.present? ? update(force) : create
    end

    def update(force = false)
      return false if changes.blank?
      begin
        json = @connection.request((force && :put || :patch), "api/#{endpoint}/#{id}/edit", { body: to_h })
        self.attributes = json[field_name.singularize]
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      self.errors.blank?
    end

    def create
      begin
        json = @connection.request(:post, "api/#{endpoint}/#{id}/new", { body: to_h })
        self.attributes = json[field_name.singularize]
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      self.errors.blank?
    end

    def destroy
      begin
        @connection.request(:delete, "api/#{endpoint}/#{id}/delete")
        true
      rescue RequestError => e
        self.errors = e.errors
        false
      end
    end

    def changes
      @table.changes
    end

    def attributes
      @table.to_h
    end

    def attributes=(hash)
      hash.each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
      end
    end

    private

    def clear_changes
      @table.instance_variable_set(:@changes, nil)
    end

    def endpoint
      self.class.endpoint
    end

    def field_name
      self.class.field_name
    end

    def assign_attributes(source = {})
      @mautic_attributes ||= []

      source.each do |key, value|
        @mautic_attributes << Attribute.new(key: key, value: value)
      end

      self.attributes = source
    end

  end
end
