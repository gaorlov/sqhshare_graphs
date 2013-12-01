class HttpHelper

  require 'net/http'

  #PREFIX = "https://rest.sqlshare.escience.washington.edu"
  PREFIX = "https://c8f74f55ccf0451387bc2224a509d6ed.cloudapp.net"
  DATASET_LIST = "/REST.svc/v2/db/dataset"
  DATASET_URI  = "/REST.svc/execute?sql="
  SQLV1 = "/REST.svc/v1/db?sql="
  SQLV2 = "/REST.svc/v2/db"
  #FULL_DATASET = "REST.svc/v1/db/file?sql=" #  &format={format}
  EXECUTE = "/REST.svc/execute?sql="
  WHOAMI  = "/REST.svc/v1/whoami"
  KEY_PREFIX = "sqlshare-graphs"
  BAG     = "/REST.svc/kvstore/"
  BAGS    = "/REST.svc/kvstore?s=#{KEY_PREFIX}"

  def self.http_get url, existing_attributes = false, api_key = nil, headers = []
    url = PREFIX + url + (api_key ? ( existing_attributes ? "&" : "?") + "auth=true&authorization=#{api_key}" : '' )
    uri = URI.parse(URI.escape(url))

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    # TODO: kill me when pointing back to production server
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #--------
    
    req = Net::HTTP::Get.new(uri.request_uri)
    headers.each do |header|
      req[header[:name]] = header[:value]
    end

    data = http.request(req)
    return data.body
  end
  
  def self.http_post url, data, headers = []
    url = PREFIX + url
    
    uri = URI.parse(URI.escape(url))
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    
    # TODO: kill me when pointing back to production server
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #--------

    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = data.to_s

    headers.each do |header|
      req[header[:name]] = header[:value]
    end

    res = https.request(req)
  end


  def self.parse_data columns, data
    parsed_data = []
    columns.each do |col|
      parsed_data << {"key" => col["name"], "values" => []}
    end
    # we assume the same order
    data.each do |datum|
      datum.each_with_index do |value, i|
        parsed_data[i]["values"] << value
      end
    end
    return parsed_data
  end
end