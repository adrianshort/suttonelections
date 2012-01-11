require 'data_mapper'
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

class Candidate
  include DataMapper::Resource

  property  :id,              Serial
  property  :forenames,       String,   :required => true
  property  :surname,         String,   :required => true
  property  :sex,             String
  
  has n, :candidacies
  
  def short_name
    @forenames.split(' ')[0] + ' ' + @surname
  end
  
  def name
    @forenames + ' ' + @surname
  end
end

class Candidacy
  include DataMapper::Resource

  property  :id,                Serial
  property  :election_id,       Integer, :required => true  
  property  :candidate_id,      Integer, :required => true
  property  :party_id,          Integer
  property  :district_id,       Integer, :required => true
  property  :votes,             Integer
  property  :address,           String,  :length => 200
  property  :postcode,          String
  property  :position,          Integer
  property  :elected,           Boolean
  property  :seats,             Integer

  belongs_to  :election
  belongs_to  :candidate
  belongs_to  :party
  belongs_to  :district
end

class Election
  include DataMapper::Resource

  property  :id,                Serial
  property  :body_id,           Integer, :required => true
  property  :d,                 Date, :required => true
  property  :reason,            String, :length => 255
  property  :kind,              String, :length => 255
  
  has n,      :candidacies
  belongs_to  :body
  
  def self.past
    self.all(:d.lt => Time.now.to_s, :order => [ :d.desc ])
  end
  
  def self.future
    self.all(:d.gte => Time.now.to_s, :order => [ :d.desc ])
  end
  
end

class District
  include DataMapper::Resource

  property  :id,                Serial
  property  :body_id,           Integer,  :required => true
  property  :name,              String,   :length => 255, :required => true
  property  :slug,              String
  property  :seats,             Integer
  
  belongs_to :body
  
  def self.slugify(name)
    name.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-').downcase
  end
end

class Body
  include DataMapper::Resource

  property  :id,                 Serial
  property  :name,               String, :length => 255, :required => true
  property  :district_name,      String, :length => 255, :required => true # singular
  property  :districts_name,     String, :length => 255, :required => true # plural
  property  :slug,               String, :length => 255
  
  has n,  :elections
  has n,  :districts
end

class Party
  include DataMapper::Resource
  
  property :id,             Serial
  property :name,           String,   :required => true
  property :colour,         String
  
  has n, :candidates, :order => ['surname']
  
  has n, :councilcandidates, :order => ['surname']
  has n, :parliamentcandidates, :order => ['surname']
end

# These models are now redundant

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

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/suttonelections.db")
DataMapper.auto_upgrade!