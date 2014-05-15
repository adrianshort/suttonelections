require 'data_mapper'

class Poll
  include DataMapper::Resource

  property :district_id,          Integer, :key => true
  property :election_id,          Integer, :key => true
  property :electorate,           Integer                       # The number of people eligible to vote in this district in this election
  property :ballot_papers_issued, Integer                       # The number of ballot papers issued (includes spoiled ballots)
  property :seats,                Integer, :required => true    # The number of seats to be elected in this district in this election
  
  def turnout_percent
    @ballot_papers_issued.to_f / @electorate.to_f * 100.0
  end

  belongs_to :election
  belongs_to :district
end

class Postcode
  include DataMapper::Resource

  # Postcode natural key, uppercase with space, eg. "SM1 1EA"
  # Column names derived from Ordnance Survey CodePoint Open
  property :postcode,                     String,   :key => true
  property :positional_quality_indicator, Integer
  property :eastings,                     Integer,  :required => true
  property :northings,                    Integer,  :required => true
  property :country_code,                 String,   :required => true
  property :nhs_regional_ha_code,         String,   :required => true
  property :nhs_ha_code,                  String,   :required => true
  property :admin_county_code,            String # NULL within Greater London
  property :admin_district_code,          String,   :required => true # e.g. London Borough of Sutton
  property :admin_ward_code,              String,   :required => true # e.g. Sutton Central
  property :lat,                          Float,    :required => true
  property :lng,                          Float,    :required => true
  property :ward_id,                      Integer,  :required => true # Sutton Council
  property :constituency_id,              Integer,  :required => false # UK Parliament

  belongs_to :district, :child_key => [:ward_id]

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
  property  :surname,         String,   :required => true, :index => true
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
  property  :position,          Integer # Position of this candidate in this district. (1..n)
  property  :seats,             Integer # Number of seats won by this candidacy (0 or 1)
  property  :labcoop,           Boolean, :default => false # Candidacy is for joint Labour/Co-op party

  belongs_to  :election
  belongs_to  :candidate
  belongs_to  :party
  belongs_to  :district
end

class Election
  include DataMapper::Resource

  property  :id,                Serial
  property  :body_id,           Integer, :required => true
  property  :d,                 Date, :required => true, :index => true
  property  :reason,            String, :length => 255
  property  :kind,              String, :length => 255
  
  has n,      :candidacies
  has n,      :polls
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
  property  :ons_district_code, String

  belongs_to :body
  has n,    :postcodes, :child_key => [:ward_id]
  has n,    :polls
  
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
  
  has n, :candidacies
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

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres@localhost:5432/suttonelections")
DataMapper.auto_upgrade!
