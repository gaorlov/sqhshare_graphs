class SessionsController < ApplicationController
  def new
    @title = "Credentials"
  end
  # TODO: Kill me if you get devise going ever
  def store_api_key
    if !params[:key][:api_key] || params[:key][:api_key] == ""
      render :json => {:status => 'failure', :error => "Key cannot be empty"}
    else
      session[:api_key] = params[:key][:api_key]
      render :json => {:status => 'success', :value => {"api_key" => session[:api_key]}}
    end
  end
end