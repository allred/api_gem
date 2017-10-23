require "api_gem/version"
require "rest-client"
require "json"

module ApiGem
  class Client
    attr_accessor :uri_base, :uri_authenticate, :token, :username, :password

    def initialize(args={})
      @uri_base = 'http://todoable.teachable.tech/api'
      @uri_authenticate = "#{@uri_base}/authenticate"
      @token = nil
      @username = ENV['api_gem_username']
      @password = ENV['api_gem_password']
    end

    def get_params(method, uri, payload={}, headers={})
      params = []
      if @token.eql? nil
        get_token
      end
      headers.merge!({Authorization: %Q%Token token=#{@token}%})
      if method.eql? 'get' or method.eql? 'delete'
        params = [method, uri, headers]
      else
        params = [method, uri, payload.to_json, headers] 
      end
      return params
    end

    def req(method, uri, payload={}, headers={})
      begin
        response = RestClient.send(*get_params(method, uri, payload, headers))
      rescue RestClient::Unauthorized
        @token = nil
        response = RestClient.send(*get_params(method, uri, payload, headers))
      rescue RestClient::UnprocessableEntity
        puts "#{method} error: Unprocessable Entity"
      rescue RestClient::NotFound
        puts "#{method} error: Not Found"
      end
      return response
    end

    def get_all_lists()
      req("get", "#{@uri_base}/lists")
    end

    def get_list(id)
      id.gsub!(/http.*\//, '') if id =~ /^http/
      req("get", "#{@uri_base}/lists/#{id}")
    end

    def create_list(list)
      req("post", "#{@uri_base}/lists", list)
    end

    def update_list(id, list)
      id.gsub!(/http.*\//, '') if id =~ /^http/
      req("patch", "#{@uri_base}/lists/#{id}", list)
    end

    def delete_list(id)
      id.gsub!(/http.*\//, '') if id =~ /^http/
      req("delete", "#{@uri_base}/lists/#{id}")
    end

    def create_item(list_id, item)
      list_id.gsub!(/http.*\//, '') if list_id =~ /^http/
      req("post", "#{@uri_base}/lists/#{list_id}/items", item)
    end

    def finish_item(list_id=nil, item_id=nil, src=nil)
      if src
        list_id, item_id = src.match(/^http.*lists\/(.*?)\/items\/(.*?)$/).captures
      end
      req("put", "#{@uri_base}/lists/#{list_id}/items/#{item_id}/finish")
    end

    def delete_item(list_id=nil, item_id=nil, src=nil)
      if src
        list_id, item_id = src.match(/^http.*lists\/(.*?)\/items\/(.*?)$/).captures
      end
      req("delete", "#{@uri_base}/lists/#{list_id}/items/#{item_id}")
    end

    def get_token
      rc = RestClient::Resource.new(@uri_authenticate, @username, @password)
      json_token = rc.send('post', {})
      token = JSON.parse(json_token).fetch('token')
      @token = token
      return token
    end
  end
end
