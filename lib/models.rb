class Postcode
  include DataMapper::Resource

  property :id,             Serial
  property :postcode,       String,  :required => true
  property :created_at,     DateTime
  property :lat,            Float
  property :lng,            Float
  property :district_name,  String
  property :district_code,  String
  property :ward_name,      String
  property :ward_code,      String
end

class Ward
  include DataMapper::Resource
  
  property :id,             Serial
  property :ons_id,         String, :required => true
  property :name,           String, :required => true
  
  has n, :councilcandidates
end

class Party
  include DataMapper::Resource
  
  property :id,             Serial
  property :name,           String, :required => true
  
  has n, :councilcandidates
end

class Councilcandidate
  include DataMapper::Resource
  
  property :id,             Serial
  property :ward_id,        Integer, :required => true
  property :party_id,       Integer, :required => true
  property :forenames,      String
  property :surname,        String
  property :address,        String, :length => 200
  property :postcode,       String

  belongs_to :party
  belongs_to :ward

end