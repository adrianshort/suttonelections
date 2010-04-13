require 'rubygems'
require 'sinatra'
require 'pat'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db.sqlite3")

class Postcode
  include DataMapper::Resource

  property :id,             Integer, :serial => true
  property :postcode,       String,  :required => true
  property :created_at,     DateTime
  property :lat,            Float
  property :lng,            Float
  property :district_name,  String
  property :district_code,  String
  property :ward_name,      String
  property :ward_code,      String
end

DataMapper.auto_upgrade!

get '/' do
  haml :home
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase
  result = Pat.get(@postcode)
  @district_name = result['administrative']['district']['title']
  @ward_name = result['administrative']['ward']['title']
  haml :wards
end

get '/how-the-election-works' do
  haml :election
end

# get '/voting' do
#   haml :voting
# end

get '/about' do
  @accounts = %w{ adrianshort mashthestate openlylocal openelection lbsuttonnews stef stonecothill sutmoblib mysociety pezholio stonecotparking }
  haml :about
end
