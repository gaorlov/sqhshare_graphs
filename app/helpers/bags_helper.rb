module BagsHelper
  def get_bags username
    HttpHelper.http_get( "#{HttpHelper::BAGS}-#{username}", true,  )
  end
end