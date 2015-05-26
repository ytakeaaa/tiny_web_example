# -*- coding: utf-8 -*-

module WebAPIClient
  class Comment < ApiResource
    class << self
      def index
        send_request(Net::HTTP::Get, "comments")
      end

      def show(id)
        send_request(Net::HTTP::Get, "comments/#{id}")
      end

      def create(params = nil)
        send_request(Net::HTTP::Post, "comments", params)
      end

      def update(id, params = nil)
        send_request(Net::HTTP::Put, "comments/#{id}", params)
      end

      def delete(id)
        send_request(Net::HTTP::Delete, "comments/#{id}")
      end
    end
  end
end
