# Import postcode data from CodePoint Open

require 'csv'
require_relative "../app"

i = 0

CSV.foreach(ARGV.shift) do |row|
  i += 1
  next if i == 1 # skip header row
  puts i
  puts row
  puts 
  
  ward = District.first(:ons_district_code => row[9])
  
  puts Postcode.create!(
    :postcode => row[0],
    :positional_quality_indicator => row[1],
    :eastings => row[2],
    :northings => row[3],           
    :country_code => row[4],          
    :nhs_regional_ha_code => row[5],      
    :nhs_ha_code => row[6],
    :admin_county_code => row[7],        
    :admin_district_code => row[8],  
    :admin_ward_code => row[9],
    :lat => row[10],    
    :lng => row[11],               
    :ward_id => ward.id
  )    
end
