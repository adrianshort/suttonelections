require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-aggregates'
require 'pat'

class Postcode
  include DataMapper::Resource

  # Postcode natural key, uppercase with space, eg. "SM1 1EA"
  property :postcode,       String,   :key => true
  property :created_at,     DateTime
  property :updated_at,     DateTime
  property :lat,            Float,    :required => true
  property :lng,            Float,    :required => true
  property :district_name,  String,   :required => true
  property :district_code,  String,   :required => true
  property :ward_name,      String,   :required => true
  property :ward_code,      String,   :required => true
  
  def self.finder(postcode)
    postcode = postcode.strip.upcase
    
    if o = self.get(postcode)
      return o
    end

    result = Pat.get(postcode)

    unless result.code == 404
      # cache API result
      self.create(
        :postcode => postcode,
        :lat => result['geo']['lat'],
        :lng => result['geo']['lng'],
        :district_name => result['administrative']['district']['title'],
        :district_code => result['administrative']['district']['uri'].match(/.+\/(.+)$/)[1],
        :ward_name => result['administrative']['ward']['title'],
        :ward_code => result['administrative']['ward']['uri'].match(/.+\/(.+)$/)[1]
      )
    else
      # invalid postcode
      nil
    end
    
  end
end

class Ward
  include DataMapper::Resource
  
  property :id,               Serial
  property :slug,             String,   :required => true
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
  property :colour,         String
  
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
  property :votes_2010,     Integer
  
  belongs_to :party
  belongs_to :ward
end

class Parliamentcandidate
  include DataMapper::Resource
  
  property :id,                 Serial
  property :constituency_id,    Integer,  :required => true
  property :party_id,           Integer,  :required => true
  property :forenames,          String,   :required => true
  property :surname,            String,   :required => true
  property :address,            String,   :length => 200
  property :postcode,           String
  property :votes_2010,         Integer
  property :votes_2005,         Integer
  property :percent_2005,       Float
  

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