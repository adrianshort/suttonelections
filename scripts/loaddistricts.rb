require './app'
require 'pp'

# Load wards as districts

# Ward.all.each do |ward|
#   District.create(
#     :body_id => 1,
#     :name => ward.name,
#     :slug => ward.slug
#   )
# end

# Load constituencies as districts

# Constituency.all.each do |c|
#   District.create(
#     :body_id => 2,
#     :name => c.name,
#     :slug => c.name.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-').downcase
#   )
# end

# Load council candidates as candidates

# Councilcandidate.all.each do |old_c|
#   new_c = Candidate.create!(
#     :forenames => old_c.forenames,
#     :surname => old_c.surname,
#   )
#   
#   if new_c.saved?
#     puts "Created %s OK" % new_c.surname
#   else
#     pp new_c
#   end
#   
#   candidacy = Candidacy.create!(
#     :election_id =>   1,
#     :candidate =>     new_c,
#     :party_id =>      old_c.party_id,
#     :district =>      District.first(:slug => old_c.ward.slug),
#     :votes =>         old_c.votes_2010,
#     :address =>       old_c.address,
#     :postcode =>      old_c.postcode
#   )
# 
#   if candidacy.saved?
#     puts "Candidacy created ok"
#   else
#     pp candidacy
#   end
# end

# Load parliamentary candidates

Parliamentcandidate.all.each do |old_c|
  new_c = Candidate.first_or_create(
    :forenames => old_c.forenames,
    :surname => old_c.surname,
  )
  
  if new_c.saved?
    puts "Created %s OK" % new_c.surname
  else
    pp new_c
  end
  
  
  unless old_c.votes_2010.nil?
    candidacy = Candidacy.create!(
      :election_id =>       2,
      :candidate =>         new_c,
      :party_id =>          old_c.party_id,
      :district_id =>       old_c.constituency_id == 1 ? 19 : 20,
      :votes =>             old_c.votes_2010,
      :address =>           old_c.address,
      :postcode =>          old_c.postcode
    )
  end
  
  if candidacy.saved?
    puts "2010 candidacy created ok"
  else
    pp candidacy
  end
  
end