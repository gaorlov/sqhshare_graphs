class GraphsController < ApplicationController
  def index
    @title = "Data Sets"
  end

  def new
    @title = "New Query"
  end

  def dataset

  end

  def sample_bag # create its own controller when making the full thing

    id = params[:id]

    @title = "Graph Bag: Seaflow Visualizations"

    coffee_set = {:sql => 'select year, sum(price) as price, sum(value) as value, sum(pounds) as pounds from [gbc3].[coffee prices.csv] group by year', :y_axes => "price, value, pounds", :x_axis => "year", :graph_type => "bar", :height => 400}
    elements_set = {:sql =>  'select * from [akey7].[full_elements.csv]', :y_axes => "boil_kelvin, melt_kelvin, first_ionization_ev", :x_axis => 'z', :graph_type => 'line_with_scale', :height => 400}
    
    @graphs = []
    @graphs << {:sql => "select lat, lon, unixtimestamp from [seaflow.viz@gmail.com].[sds_view] order by unixtimestamp asc", :y_axes => "lat,lon", :x_axis => "unixtimestamp", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from [seaflow.viz@gmail.com].[seaflow: stream pressure vs time] order by [datetime] asc", :y_axes => "STREAM.PRESSURE", :x_axis => "DateTime", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from [seaflow.viz@gmail.com].[seaflow: evt-opp ratio vs time] order by [datetime] asc", :y_axes => "EVT/OPP", :x_axis => "DateTime", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from [seaflow.viz@gmail.com].[SeaFlow: D1D2 vs Time] order by [datetime] asc", :y_axes => "D1.D2", :x_axis => "DateTime", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from [seaflow.viz@gmail.com].[SeaFlow: population-wise concentrations] order by [datetime] asc", :y_axes => "Conc.ultra,Conc.beads,Conc.synecho,Conc.nano,Conc.pico,Conc.crypto,Conc.cocco", :x_axis => "DateTime", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from [seaflow.viz@gmail.com].[SeaFlow: beads FSC signal] order by [datetime] asc", :y_axes => "beads FSC", :x_axis => "DateTime", :graph_type => "scatter", :height => 400}
    @graphs << {:sql => "select * from (select top 500 [datetime],[velocity (m/s)] from [seaflow.viz@gmail.com].[seaflow: velocity] where [velocity (m/s)] is not null order by [datetime] desc) x order by [datetime] asc", :y_axes => "velocity (m/s)", :x_axis => "datetime", :graph_type => "scatter", :height => 400}

    @columns = @graphs.count == 1 ? 1 : 2
  end
end