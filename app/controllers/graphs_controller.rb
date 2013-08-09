class GraphsController < ApplicationController
  def index
    @title = "Data Sets"
  end

  def new
    @title = "New Query"
  end

  def dataset

  end

  def set
    @title = "Graph Set: Coffee & Elements"

    coffee_set = {:sql => 'select year, sum(price) as price, sum(value) as value, sum(pounds) as pounds from [gbc3].[coffee prices.csv] group by year', :y_axes => "price, value, pounds", :x_axis => "year", :graph_type => "bar"}
    elements_set = {:sql =>  'select * from [akey7].[full_elements.csv]', :y_axes => "boil_kelvin, melt_kelvin, first_ionization_ev", :x_axis => 'z', :graph_type => 'line_with_scale'}
    
    @graphs = [coffee_set, elements_set]
    @columns = @graphs.count == 1 ? 1 : @graphs.count > 2 ? 3 : 2
  end
end