class HttpHelper

  require 'net/http'

  PREFIX = "https://rest.sqlshare.escience.washington.edu"
  DATASET_LIST = "/REST.svc/v2/db/dataset"
  SQLV1 = "/REST.svc/v1/db?sql="
  SQLV2 = "/REST.svc/v2/db"
  #FULL_DATASET = "REST.svc/v1/db/file?sql=" #  &format={format}
  EXECUTE = "/REST.svc/execute?sql="

  def self.http_get url, existing_attributes = false
    url = PREFIX + url + (@api_key ? ( existing_attributes ? "&" : "?") + "authorization=#{@api_key}" : '' )
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    data = http.get(uri.request_uri)
    return data.body
  end
  
  def self.http_post url, fields
    url = PREFIX + url
    
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path)
    fields.each{|key, val|
      req[key] = val
    }
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