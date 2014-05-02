# Add new ONS ward codes to districts table

# E05000555

require_relative "../app"

c = 5000555

District.all(:body_id => 1, :order => [:name]).each do |d|
  d.ons_district_code = "E%08d" % c
  d.save
  puts d.name, d.ons_district_code
  c += 1
end
