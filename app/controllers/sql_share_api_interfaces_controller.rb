class SqlShareApiInterfacesController < ApplicationController

  require 'net/http'

  PREFIX = "https://rest.sqlshare.escience.washington.edu"
  DATASET_LIST = "/REST.svc/v2/db/dataset"
  SQLV1 = "/REST.svc/v1/db?sql="
  SQLV2 = "/REST.svc/v2/db"
  #FULL_DATASET = "REST.svc/v1/db/file?sql=" #  &format={format}
  EXECUTE = "/REST.svc/execute?sql="

  def dataset_list
    render :json => {:status => 'success', :value => http_get(DATASET_LIST) }
  end

  def data_from_sql
    url = SQLV1 + URI.escape(params[:sql]) + "&maxrows=#{params[:maxrows] || 250}"
    render :json => {:status => 'success', :value => http_get(url, true) }
  end

  def get_process_data
    url = params[:url]
    render :json => {:status => 'success', :value => http_get(url) }
  end

  def dataset
    render :status => 404 if !params[:url]
    set = http_get(URI.escape(params[:url]), params[:auth] || false)
    @set = JSON.parse(set)

    if @set["Detail"]
      @title = "Oh noes! You can haz error! : ("
      @status = @set["Detail"]
      render error_graphs_path
      return
    end

    full_set = @set["sample_data"] == nil

    if full_set

      @columns = []
      @set["header"].each_with_index do |h, i|
        @columns << {"name" => h, "dbtype" => @set["type"][i]}
      end
      data = @set["data"]

    else
      @columns = @set["columns"]
      data = @set["sample_data"]
    end
    
    @sql = @set["sql_code"] || @set["sql"]
    @x_axes = []
    @columns.each_with_index do |col|
      @x_axes << col unless ["System.String", "varchar", "string"].include? col["dbtype"]
    end
    @data = parse_data @columns, data
    name = @set['name'] || @set['sql'].gsub(/.*\]\.\[/, '').gsub(/]/, '')
    @title = "Visualize Dataset"
  end

private
  def http_get url, existing_attributes = false
    url = PREFIX + url + (@api_key ? ( existing_attributes ? "&" : "?") + "authorization=#{@api_key}" : '' )
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


  def parse_data columns, data
    parsed_data = []
    columns.each_with_index do |col|
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
