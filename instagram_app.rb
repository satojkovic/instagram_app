require 'sinatra'
require 'instagram'
require 'pit'

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |config|
  conf = Pit.get("api.instagram.com", :require => {
                   "client_id" => "your client id",
                   "client_secret" => "your client secret",
                 })
  config.client_id = conf["client_id"]
  config.client_secret = conf["client_secret"]
end

get "/" do 
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user.username}'s recent photos</h1>"
  for media_item in client.user_recent_media
    html << "<img src='#{media_item.images.thumbnail.url}'>"
    html << "<h3>#{media_item.caption}</h3>"
    html << "<br>"
  end
  html
end

  

  
