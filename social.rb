require 'typhoeus'
require 'uri'

class SocialData
  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  def fetch
    @@sources.each_with_object({}) do |source_name, share_data|
      source = source_name.constantize.new(url)
      share_data[source.symbolize] = source.shares
    end
  end

  @@sources = [
    'FacebookData',
    'TwitterData',
    'GoogleData'
  ]

  class RequestFailure < StandardError; end

  protected

  def escaped_url
    CGI.escape @url
  end

end

class FacebookData < SocialData
  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  def symbolize
    :facebook
  end

  def shares #just parses response
    response.first['total_count']
  end

  protected

  def response 
    Fql.execute(query)
  rescue Fql::Exception
    raise SocialData::RequestFailure
  end

  def query
    %{SELECT total_count FROM link_stat WHERE url="#{escaped_url}"}
  end

end

class TwitterData < SocialData

  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  def symbolize
    :twitter
  end

  def shares
    MultiJson.load(response)['count']
  end

  protected

  def response
    base_url = "http://urls.api.twitter.com/1/urls/count.json?url="
    Typhoeus::Request.get(base_url + escaped_url).body
  rescue
    raise SocialData::RequestFailure
  end

end

class GoogleData < SocialData

  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def symbolize
    :google
  end

  def shares
    response
    # shares should only be responsible for returning an integer
    # but currently resonse obj since g+ not returning json
  end

  protected

  def response
    request_url = "https://plusone.google.com/_/+1/fastbutton?url=#{escaped_url}&count=true"
    Typhoeus.get(request_url)
  rescue
    raise SocialData::RequestFailure
  end

end


# options= {:httpauth_avail=>0, :total_time=>0.085682, :starttransfer_time=>0.075863, :appconnect_time=>4.4e-05, :pretransfer_time=>0.000137, :connect_time=>4.4e-05, :namelookup_time=>4.3e-05, :effective_url=>"https://plusone.google.com/_/+1/fastbutton?url=not_a_url&count=true", :primary_ip=>"173.194.115.7", :response_code=>400, :redirect_count=>0}
# puts options[:response_code]