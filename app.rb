require 'rubygems'
require 'sinatra'
require 'sinatra-helpers/haml/partials'
require 'haml'
require 'lib/models'

get '/' do
  if params[:postcode]
    @postcode = params[:postcode].strip.upcase

    unless result = Postcode.finder(@postcode)
      # Invalid postcode
      redirect '/error'
    end
  
    # Postcode valid but not in LB Sutton
    if result.district_code != "00BF"
      redirect '/aliens'
    end
    
    # Postcode in LB Sutton
    @ward = Ward.first( :ons_id => result.ward_code )
    redirect "/wards/#{@ward.slug}/postcode/#{@postcode}"
  end
  
  haml :home
end

get '/wards/:slug/postcode/:postcode/?' do
  @ward = Ward.first(:slug => params[:slug])
  @postcode = params[:postcode]
  haml :wards
end

get '/wards/:slug/?' do
  @ward = Ward.first(:slug => params[:slug])
  haml :wards
end

get '/wards/?' do
  @wards = Ward.all
  haml :wardlist
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

not_found do
  haml :not_found
end