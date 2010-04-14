require 'rubygems'
require 'sinatra'
require 'pat'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'lib/models'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db.sqlite3")
DataMapper.auto_upgrade!

get '/' do
  @wards = Ward.all( :order => 'name' )
  haml :home
end

get '/wards/:id' do
  @ward = Ward.get(params[:id])
  @candidates = Councilcandidate.all( :ward_id => @ward.id, :order => 'surname' )
  haml :wards
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase
  result = Pat.get(@postcode)
  @district_name = result['administrative']['district']['title']
  @ward_name = result['administrative']['ward']['title']
  @ward = Ward.first( :name => @ward_name )
  @candidates = Councilcandidate.all( :ward_id => @ward.id, :order => 'surname')
  haml :wards
end

get '/how-the-election-works' do
  haml :election
end

# get '/voting' do
#   haml :voting
# end

get '/about' do
  @accounts = %w{
    adrianshort
    mashthestate
    openlylocal
    openelection
    lbsuttonnews
    stef
    stonecothill
    sutmoblib
    mysociety
    pezholio
    stonecotparking
  }
  haml :about
end
