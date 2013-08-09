class ApiController < ApplicationController
  require 'json'

  def dataset

    puts params

    if params[:sql] == nil
      render :status => 404
      return
    end
    
    set = HttpHelper.http_get(HttpHelper::EXECUTE + URI.escape(params[:sql]))
    set = JSON.parse(set)
    raise set

    y_axes = params[:y_axes] || []
    
    if y_axes.class.to_s == "String"
      y_axes = y_axes.split(",")
    end

    x_axis = params[:x_axis]
    
    data = set["data"]

    @data = generate_data y_axes, x_axis, data, set["header"]
    
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

    render :layout => false
  end

  private

  def find_index col_names, axis
    col_names.each_with_index do |col, i|
      return i if col == axis
    end
    return false
  end

  def generate_data y_axes, x_axis = null, data, col_names
    ret_data = []
    y_axes.each do |y_axis|
      y_index = find_index col_names, y_axis
      x_index = find_index col_names, x_axis
      col_data = {"key" => y_axis, "values" => []}

      data.each_with_index do |datum, i|
        if !x_axis
          col_data["values"] << {"x" => i, "y" => datum[y_index]}
        else
          col_data["values"] << {"x" => datum[x_index], "y" => datum[y_index]}
        end
      end
      ret_data << col_data
    end
    return ret_data
  end
end