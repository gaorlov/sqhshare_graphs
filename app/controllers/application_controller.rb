class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  require "http_helper"

  before_filter :set_api_key
  before_filter :set_user

  def set_api_key
    @api_key = session[:api_key]
  end

  def set_user
    @user = session[:user].gsub(/\./, '_') if session[:user]
  end
end
