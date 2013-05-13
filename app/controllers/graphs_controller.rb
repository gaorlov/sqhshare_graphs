class GraphsController < ApplicationController
  def index
    @title = "Data Sets"
  end

  def new
    @title = "Run Queries"
  end
end