require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'

get '/' do
  @wards = %w{ Cheam Sutton Stonecot }
  haml :home
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase

  url = "http://www.uk-postcodes.com/postcode/" + @postcode.gsub(/ /, '') + '.json'

  result = RestClient.get(url)
  result_ary = JSON.parse(result)
  @district_name = result_ary['administrative']['district']['title']
  @ward_name = result_ary['administrative']['ward']['title']
  haml :wards
end

get '/about' do
  haml :about
end