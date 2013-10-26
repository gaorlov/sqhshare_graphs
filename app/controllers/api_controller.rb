class ApiController < ApplicationController
  require 'json'

  def dataset

    if params[:sql] == nil
      render :status => 404
      return
    end
    
    y_axes = params[:y_axes] || []
    
    if y_axes.class.to_s == "String"
      y_axes = y_axes.split(",")
    end

    x_axis = params[:x_axis]

    axes = y_axes << x_axis
    escaped_axes = ""
    axes.each do |axis|
      escaped_axes += "[#{axis}]"
      escaped_axes += ", " unless axis == axes.last
    end

    sql = "SELECT #{escaped_axes} FROM (#{params[:sql]}) x"

    begin
      set = HttpHelper.http_get(HttpHelper::EXECUTE + URI.escape(sql))
      set = JSON.parse(set)
    rescue Exception => e
      @title = "SQL Error"
      render error_graphs_path
      return
    end
    
    @status = set["Message from SQLShare"] if set["Message from SQLShare"]

    if set["Message from SQLShare"] || !set
      @title = "Oh good heavens! This is just terrible. >:["
      render error_graphs_path
      return
    end

    data = set["data"]

    parsed_data = generate_data y_axes, x_axis, data, set["header"], set["type"].map{|i|i.downcase}
    
    if parsed_data[:status] == :failure
      @error = parsed_data[:data]
    else

      @data = parsed_data[:data]

      @include_styling = params[:styled]

      @graph_type = case params[:graph_type]
                      when "line_with_scale"
                        "lineWithFocusChart"
                      when "line"
                        "lineChart"
                      when "bar"
                        "multiBarChart"
                      else
                        "scatterChart"
                      end

      @graph_height = params[:height] || 600

    end

    render :layout => false
  end

  private

  def find_index col_names, axis
    col_names.each_with_index do |col, i|
      return i if col == axis
    end
    return false
  end

  def generate_data y_axes, x_axis = null, data, col_names, types
    ret_data = []
    y_axes.each do |y_axis|
      y_index = find_index col_names, y_axis
      x_index = find_index col_names, x_axis

      if y_index == false || x_index == false
        @error = []
        @error << "y axis \"#{y_axis}\" not found in #{col_names}" unless y_index
        @error << "x axis \"#{x_axis}\" not found in #{col_names}" unless x_index
        return {:status => :failure, :data => @error}
      end

      col_data = {"key" => y_axis, "values" => []}

      data.each_with_index do |datum, i|
        y_value = types[y_index] == "datetime" ? "new Date('#{datum[y_index]}').getTime()" : datum[y_index]
        if !x_axis
          col_data["values"] << {"x" => i, "y" => y_value }
        else
          x_value = types[x_index] == "datetime" ? "new Date('#{datum[x_index]}').getTime()" : datum[x_index]
          col_data["values"] << {"x" => x_value, "y" => y_value}
        end
      end
      ret_data << col_data
    end
    return {:status => :success, :data => ret_data}
  end
end