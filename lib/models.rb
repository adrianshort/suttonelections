require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

class Postcode
  include DataMapper::Resource

  property :id,             Serial
  property :postcode,       String,   :required => true
  property :created_at,     DateTime, :required => true
  property :lat,            Float,    :required => true
  property :lng,            Float,    :required => true
  property :district_name,  String,   :required => true
  property :district_code,  String,   :required => true
  property :ward_name,      String,   :required => true
  property :ward_code,      String,   :required => true
end

class Ward
  include DataMapper::Resource
  
  property :id,               Serial
  property :ons_id,           String,   :required => true
  property :name,             String,   :required => true
  property :constituency_id,  Integer,  :required => true
     
  has n, :councilcandidates, :order => ['surname']
  belongs_to :constituency
  
  def self.slugify(name)
    name.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-').downcase
  end
  
end

class Party
  include DataMapper::Resource
  
  property :id,             Serial
  property :name,           String,   :required => true
  
  has n, :councilcandidates, :order => ['surname']
  has n, :parliamentcandidates, :order => ['surname']
end

class Councilcandidate
  include DataMapper::Resource
  
  property :id,             Serial
  property :ward_id,        Integer,  :required => true
  property :party_id,       Integer,  :required => true
  property :forenames,      String,   :required => true
  property :surname,        String,   :required => true
  property :address,        String,   :length => 200
  property :postcode,       String,   :required => true

  belongs_to :party
  belongs_to :ward
end

class Parliamentcandidate
  include DataMapper::Resource
  
  property :id,               Serial
  property :constituency_id,  Integer,  :required => true
  property :party_id,         Integer,  :required => true
  property :forenames,        String,   :required => true
  property :surname,          String,   :required => true
  property :address,          String,   :length => 200
  property :postcode,         String

  belongs_to :party
  belongs_to :constituency
end

class Constituency
  include DataMapper::Resource
  
  property :id,             Serial
  property :name,           String,   :required => true
  
  has n, :wards, :order => ['name']
  has n, :parliamentcandidates, :order => ['surname']
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db.sqlite3")
DataMapper.auto_upgrade!