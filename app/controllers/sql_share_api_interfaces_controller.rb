class SqlShareApiInterfacesController < ApplicationController

  def dataset_list
    render :json => {:status => 'success', :value => HttpHelper.http_get(HttpHelper::DATASET_LIST) }
  end

  def data_from_sql
    url = HttpHelper::SQLV1 + URI.escape(params[:sql]) + "&maxrows=#{params[:maxrows] || 250}"
    render :json => {:status => 'success', :value => HttpHelper.http_get(url, true) }
  end

  def get_process_data
    url = params[:url]
    render :json => {:status => 'success', :value => HttpHelper.http_get(url) }
  end

  def dataset


    if params[:layout] == "false"
      render "white_label_dataset"
      return
    end

    if !params[:url].present?
      render :status => 404 
      return
    end
    set  = HttpHelper.http_get(URI.escape(params[:url]), params[:auth] || false)
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
    @data = HttpHelper.parse_data @columns, data
    name = @set['name'] || @set['sql'].gsub(/.*\]\.\[/, '').gsub(/]/, '')
    @title = "Visualize Dataset"


    @graph_height     = params[:height]     || false
    @selected_x_axis  = params[:x_axis]     || false
    @selected_y_axes  = params[:y_axes]     || false
    @graph_type       = params[:graph_type] || false
    @render_on_load   = params[:render]     || false
    @sqlshare_path    = params[:url]

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
