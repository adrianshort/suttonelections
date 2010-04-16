require 'rubygems'
require 'sinatra'
require 'sinatra-helpers/haml/partials'
require 'haml'
require 'pat'
require 'lib/models'

get '/' do
  haml :home
end

get '/wards/:id' do
  @ward = Ward.get(params[:id])
  haml :wards
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase
  result = Pat.get(@postcode)

  # Invalid postcode
  if result.code == 404
    redirect '/error'
  end

  # Postcode valid but not in LB Sutton
  if result['administrative']['district']['title'] != "Sutton London Borough Council"
    redirect '/aliens'
  end
  
  # Postcode in LB Sutton
  @ward = Ward.first( :name => result['administrative']['ward']['title'] )
  
  haml :wards
end

get '/how-the-council-election-works' do
  haml :election
end

get '/how-the-parliament-election-works' do
  haml :parliament
end

# get '/voting' do
#   haml :voting
# end

get '/error' do
  haml :error
end

get '/about' do
  haml :about
end

get '/aliens' do
  haml :aliens
end