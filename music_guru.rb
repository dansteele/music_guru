require 'echowrap'
require 'sinatra'
require 'rack-flash'
require 'json'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash

configure do
  Echowrap.configure do |config|
    config.api_key = ENV['API_KEY'] || File.read('api.key')
  end
end

get '/' do
  erb :index
end

post '/tracks' do
  fingerprint = `ENMFP_codegen/codegen.Linux-x86_64 #{params[:track][:tempfile].path} 10 20`
  code = JSON.parse(fingerprint).first["code"]
  song = Echowrap.song_identify(:code => code)

  if song.nil?
    flash[:notice] = "Er.. you've got me..."
  else
    flash[:notice] = "Was your song #{song.title} by #{song.artist_name}?"
  end

  redirect '/'
end