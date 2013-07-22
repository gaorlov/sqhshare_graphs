class ApplicationController < ActionController::Base
  protect_from_forgery

  require "http_helper"

  before_filter :set_api_key

  def set_api_key
    @api_key = session[:api_key]
  end
end
