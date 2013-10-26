class SqlShareApiInterfacesController < ApplicationController
  require 'pp'

  def dataset_list
    render :json => {:status => 'success', :value => HttpHelper.http_get(HttpHelper::DATASET_LIST) }
  end

  def dataset

    if params[:layout] == "false"
      render "white_label_dataset"
      return
    end

    if !params[:sql].present?
      render :status => 404 
      return
    end

    set, @set = nil

    begin
      set = HttpHelper.http_get(HttpHelper::EXECUTE + URI.escape(params[:sql]), true, @api_key)
      @set = JSON.parse(set)
    rescue Exception => e
      @title = "SQLShare Error"
      @sql_share_error = e.to_s
      render error_graphs_path
      return
    end

    @status = @set["Message from SQLShare"] if @set["Message from SQLShare"]

    if @set["Message from SQLShare"] || !@set
      @title = "Oh noes! You can haz error! : ("
      render error_graphs_path
      return
    end

    @columns = []
    @set["header"].each_with_index do |h, i|
      @columns << {"name" => h, "dbtype" => @set["type"][i]}
    end
    data = @set["data"]

    @sql = @set["sql"]
    @x_axes = []
    @columns.each_with_index do |col|
      @x_axes << col unless ["System.String", "varchar", "string"].include? col["dbtype"]
    end
    @data = HttpHelper.parse_data @columns, data
    name = @set['sql'].gsub(/.*\]\.\[/, '').gsub(/]/, '')
    @title = "Visualize Dataset"


    @graph_height     = params[:height]     || false
    @selected_x_axis  = params[:x_axis]     || false
    @selected_y_axes  = params[:y_axes]     || false
    @graph_type       = params[:graph_type] || false
    @render_on_load   = params[:render]     || false
    @sqlshare_path    = HttpHelper::DATASET_URI + params[:sql]

    if @graph_type
      @graph_type = 
        case @graph_type
          when "scatter"
            "Scatter Plot"
          when "line_with_scale"
            "Line Chart With Zoom"
          when "line"
            "Simple Line Chart"
          when "bar"
            "Bar Chart"
          else
            false
        end
    end
  end
end
