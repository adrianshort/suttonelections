require 'data_mapper'

class Poll
  include DataMapper::Resource

  property :district_id,          Integer, :key => true
  property :election_id,          Integer, :key => true
  property :electorate,           Integer                       # The number of people eligible to vote in this district in this election
  property :ballot_papers_issued, Integer                       # The number of ballot papers issued (includes spoiled ballots)
  property :seats,                Integer, :required => true    # The number of seats to be elected in this district in this election
  property :rejected_no_official_mark,    Integer
  property :rejected_too_many_candidates, Integer
  property :rejected_identifiable_voter,  Integer
  property :rejected_blank_or_uncertain,  Integer

  def turnout_percent
    @ballot_papers_issued.to_f / @electorate.to_f * 100.0
  end

  def total_rejected_ballots
    if @rejected_no_official_mark
      @rejected_no_official_mark + \
      @rejected_too_many_candidates + \
      @rejected_identifiable_voter + \
      @rejected_blank_or_uncertain
    else
      nil
    end
  end

  def valid_ballot_papers
    self.total_rejected_ballots ? @ballot_papers_issued - self.total_rejected_ballots : nil
  end
  
  def successful_candidacies # Candidacies where the candidate was elected
    Candidacy.all(:election => @election, :district => @district, :order => [:position], :limit => @seats)
  end
  
  # Set candidacy.position for every candidacy in this poll
  # Returns array of candidacies, or false if we don't have results for this poll
  def set_positions
    # Check that every candidacy for this poll has its votes recorded (ie that the election results are known)
    return false if Candidacy.count(:conditions => { :district_id => @district_id, :election_id => @election_id, :votes => nil }) > 0

    # Get the candidacies for this poll
    ccys = Candidacy.all(:conditions => { :district_id => @district_id, :election_id => @election_id }, :order => [:votes.desc])

    puts "Found no candidacies for this poll" if ccys.size == 0

    position = 1
    ccys.each do |ccy|
      position <= @seats ? ccy.seats = 1 : ccy.seats = 0
      ccy.position = position
      ccy.save
      position += 1
    end
    ccys
  end

  belongs_to :election
  belongs_to :district
end

class PollingStation
  include DataMapper::Resource

  property :id,           String, :key => true, :length => 2 # e.g. "KA"
  property :name,         String, :length => 255#, :required => true
  property :address,      String, :length => 255#, :required => true
  property :postcode,     String#, :required => true
  property :easting,      Float,  :required => true
  property :northing,     Float,  :required => true
  property :lat,          Float,  :required => true
  property :lng,          Float,  :required => true

  has n, :postcodes
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
  property :polling_station_id,           String,   :length => 2

  belongs_to :district, :child_key => [:ward_id]
  belongs_to :polling_station

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

  has n, :candidacies
  
  def short_name
    @forenames.split(' ')[0] + ' ' + @surname
  end
  
  def name
    @forenames + ' ' + @surname
  end
  
  def url
    "/candidates/" + @id.to_s
  end
end

class DeletedCandidate
  include DataMapper::Resource

  property  :old_candidate_id,  Integer, :key => true       # ID of candidate that has been merged/deleted
  property  :candidate_id,      Integer, :required => true  # ID of candidate that has been kept
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

class Campaign
  include DataMapper::Resource

  property :party_id,           Integer, :key => true
  property :election_id,        Integer, :key => true
  property :party_url,          String, :length => 255
  property :manifesto_html_url, String, :length => 255
  property :manifesto_pdf_url,  String, :length => 255

  belongs_to :party
  belongs_to :election
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
  has n,      :campaigns

  def self.past
    self.all(:d.lt => Time.now.to_s, :order => [ :d.desc ])
  end
  
  def self.future
    self.all(:d.gte => Time.now.to_s, :order => [ :d.desc ])
  end
  
  # electorate and ballot_papers_issued assume there's a Poll object for every district in this election
  def electorate  
    Poll.sum(:electorate, :election => self)
  end

  def ballot_papers_issued
    Poll.sum(:ballot_papers_issued, :election => self)
  end
  
  def set_positions
    polls.each { |p| p.set_positions }
  end
end

class District
  include DataMapper::Resource

  property  :id,                Serial
  property  :body_id,           Integer,  :required => true
  property  :name,              String,   :length => 255, :required => true
  property  :slug,              String
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
  has n, :campaigns
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres@localhost:5432/suttonelections")
DataMapper.auto_upgrade!
