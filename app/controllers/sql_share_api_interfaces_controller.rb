class SqlShareApiInterfacesController < ApplicationController

  require 'net/http'

  PREFIX = "https://rest.sqlshare.escience.washington.edu"
  DATASET_LIST = "/REST.svc/v2/db/dataset"
  SQLV1 = "/REST.svc/v1/db?sql="
  SQLV2 = "/REST.svc/v2/db"

  def dataset_list
    render :json => {:status => 'success', :value => http_get(DATASET_LIST) }
  end

  def data_from_sql
    data_from_sql_v1 params
  end

  def data_from_sql_v1 params
    url = SQLV1 + URI.escape(params[:sql]) + "&maxrows=#{params[:maxrows] || 250}"
    render :json => {:status => 'success', :value => http_get(url, true) }
  end


  def data_from_sql_v2 params
    url = SQLV1
    fields = { "sql" => params[:sql] }
    fields["max_records"] = params[:maxrows] || 250
    fields["authorization"] = @api_key if @api_key
    render :json => {:status => 'success', :value => http_post(url, fields) }
  end

  def get_process_data
    url = params[:url]
    render :json => {:status => 'success', :value => http_get(url) }
  end

private
  def http_get url, existing_attributes = false
    url = PREFIX + url + (@api_key ? ( existing_attributes ? "&" : "?") + "authorization=#{@api_key}" : '' )
    puts url
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    data = http.get(uri.request_uri)
    return data.body
  end
  
  def http_post url, fields
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
end
