require 'rubygems'
require 'sinatra'
require 'haml'
require 'pat'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'lib/models'

get '/' do
#   @wards = Ward.all( :order =>  ['name' ] )
  haml :home
end

get '/wards/:id' do
  @ward = Ward.get(params[:id])
  @council_candidates = Councilcandidate.all( :ward_id => @ward.id, :order => 'surname' )
   @parly_candidates = Parliamentcandidate.all( :constituency_id => @ward.constituency.id, :order => 'surname')
  haml :wards
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase
  result = Pat.get(@postcode)
  @district_name = result['administrative']['district']['title']
  @ward_name = result['administrative']['ward']['title']
  @ward = Ward.first( { :name => @ward_name } )
  @council_candidates = Councilcandidate.all( :ward_id => @ward.id, :order => 'surname')
  @parly_candidates = Parliamentcandidate.all( :constituency_id => @ward.constituency.id, :order => 'surname')
  haml :wards
end

get '/how-the-council-election-works' do
  haml :election
end

# get '/voting' do
#   haml :voting
# end

get '/about' do
  @accounts = %w{
    adrianshort
    stef
    pezholio
    countculture
    understood
    mashthestate
    openlylocal
    openelection
    lbsuttonnews
    suttongisteam
    stonecothill
    sutmoblib
    mysociety
  }
  haml :about
end
