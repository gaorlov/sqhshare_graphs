class BagsController < ApplicationController
  def index
    @title = "Bags: graph collections"
  end

  def create
    @bag = params[:bag]
    @data = create_update_bag @bag
    render :json => @data
  end

  def new
    @title = "Success! New bag created."
  end

  def show
    @title = "Bag '#{params[:id]}'"
    bag  = get_bag params[:id], false, params[:user_id]
    @graphs = bag["graphs"]
    @columns = @graphs.count == 1 ? 1 : 2 if @graphs
  end

  def whoami
    if @api_key
      begin
        get_user_name! unless @user
        render :json => {:status => :success, :data => @user}
      rescue Exception => e
        render :json => {:status => :failure, :error => e.to_s}
      end
    else
      render :json => {:status => :failure, :error => "API key missing"}
    end
  end

  def list
    if @api_key
      begin
        get_user_name! unless @user
        data = HttpHelper.http_get "#{HttpHelper::BAGS}-bag-#{@user}", true, @api_key, HEADERS
        data = JSON.parse(data)
        if data.class != Array && data["Detail"]
          if data["Detail"].count("No keys found with prefix:") != 0
            status = :success
            @data = :no_bags
          else
            status = :failure
            error = data["detail"]
          end
        else
          bags = []
          data.each do |bag|
            bags << get_bag(bag, true)
          end
          @data = bags
        end
      rescue Exception => e
        status = :failure
        error = e.to_s + "\n\n" + e.backtrace.join("\n")
      end
    else
      status = :failure
      error = "API key missing"
    end
    if status == :failure
      @title  = "Whoops! That's not good."
      @status = error
      render error_graphs_path
      return
    end
    respond_to do |format|
      format.html{ render :layout => false }
      format.json{ render :json => @data}
    end
  end

  def add_to_bag
    graph_details = params[:graph]
    bag = get_bag graph_details.delete(:name)
    bag["graphs"] = [] unless bag["graphs"]
    graph = {:sql => params[:graph][:sql]}
    graph[:x_axis] = params[:graph][:x_axis]
    graph[:y_axes] = params[:graph][:y_axes].split(",")
    graph[:graph_type] = params[:graph][:graph_type]
    graph[:height] = params[:graph][:height]
    bag["graphs"] << graph
    data = create_update_bag bag
    render :json => data
  end

  private

  HEADERS = [{:name => 'Authorization', :value => "ss_apikey sqlsharegraphs@gmail.com: f5319f5dea4da2c2de57cc9b0d8ab04f"}, {:name => "content-type", :value => "text"}]

  def get_user_name!
    data = HttpHelper.http_get HttpHelper::WHOAMI, false, @api_key
    user = JSON.parse(data)
    session[:user] = user["username"]
    @user = session[:user].gsub(/\./, '_')
  end

  def get_bag bag, full_name = false, user = nil
    user ||= @user
    bag_details = HttpHelper.http_get "#{HttpHelper::BAG}#{full_name ?  bag : full_bag_name(bag, user)}", false, @api_key, HEADERS
    # because the returned string is in the format of '"{json:strng}"'', we do nasty regexp. : (
    return JSON.parse(bag_details.gsub(/"{(?<thing>.*)}"/, '{\k<thing>}').gsub(/\\/, ''))
  end

  def full_bag_name bag, user = nil
    user ||= @user
    return "#{HttpHelper::KEY_PREFIX}-bag-#{user}-#{bag}"
  end

  def create_update_bag bag_hash
    begin
      get_user_name! unless @user
      bag = bag_hash.to_json
      data = HttpHelper.http_post "#{HttpHelper::BAG}#{full_bag_name(bag_hash["name"])}", bag, HEADERS
      return {:status => :success, :data => data}
    rescue Exception => e
      return {:status => :failure, :error => format_exception(e)}
    end
  end
end