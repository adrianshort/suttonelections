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
  
  property :id,             Serial
  property :ons_id,         String,   :required => true
  property :name,           String,   :required => true
  
  has n, :councilcandidates
end

class Party
  include DataMapper::Resource
  
  property :id,             Serial
  property :name,           String,   :required => true
  
  has n, :councilcandidates
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