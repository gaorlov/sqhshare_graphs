class GraphsController < ApplicationController
  def index
    @api_key = session[:api_key]
  end

  def store_api_key
    if !params[:key][:api_key] || params[:key][:api_key] == ""
      render :json => {:status => 'failure', :error => "Key cannot be empty"}
    else
      session[:api_key] = params[:key][:api_key]
      render :json => {:success => 'success', :value => {"api_key" => session[:api_key]}}
    end
  end
end