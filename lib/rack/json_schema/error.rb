module Rack
  module JsonSchema
    class Error < StandardError
      # @return [Array] Rack response
      def to_rack_response
        [status, headers, [body]]
      end

      private

      # @note Override this
      def status
        500
      end

      # @note Override this
      def id
        "internal_server_error"
      end

      def headers
        { "Content-Type" => "application/json; charset=utf-8" }
      end

      def body
        JSON.pretty_generate(id: id, message: message) + "\n"
      end
    end
  end
end
