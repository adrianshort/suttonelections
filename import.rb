require 'rubygems'
require 'csv'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'lib/models'

# Import wards
# 
# CSV::Reader.parse(File.open('wards.csv', 'rb')) do |row|
#     p row
#     Ward.create(
#       'ons_id'  => row[0],
#       'name'    => row[1]
#     )
# end
# 
# Define parties

# parties = [
#   "British National Party",
#   "Christian Peoples Alliance",
#   "Conservative Party",
#   "Green Party",
#   "Labour Party",
#   "Labour and Co-Operative Party",
#   "Liberal Democrats",
#   "United Kingdom Independence Party",
#   "Libertarian Party"
# ]
# 
# for party in parties
#   puts party
#   Party.create( :name => party )
# end

# Import council candidates

# CSV::Reader.parse(File.open('../candidates-pretty.csv', 'rb')) do |row|
#     p row
#     
#     c = Councilcandidate.new(
#       'forenames'   => row[1],
#       'surname'     => row[2],
#       'address'     => row[4],
#       'postcode'    => row[5]
#     )
# 
#     c.ward = Ward.first( :name => row[0] )
#     c.party = Party.first( :name => row[3] )    
# 
#     unless c.save
#       puts "ERROR: Failed to save candidate"
#       c.errors.each do |e|
#         puts e
#       end
#     end
# end

# Import parliament candidates

CSV::Reader.parse(File.open('../parliament-candidates.csv', 'rb')) do |row|
    p row
    
    c = Parliamentcandidate.new(
      'forenames'   => row[1],
      'surname'     => row[2]
    )

    c.constituency = Constituency.first( :name => row[3] )
    c.party = Party.first( :name => row[0] )    

    unless c.save
      puts "ERROR: Failed to save candidate"
      c.errors.each do |e|
        puts e
      end
    end
end
