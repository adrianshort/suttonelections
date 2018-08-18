require 'csv'
require './models'

CSV.foreach(ARGV.shift) do |row|
  pc = row[0].strip
  puts pc
  if @postcode = Postcode.get(pc)
    @postcode.polling_station_id = row[1]
    @postcode.save
  else
    puts "#{pc} not found"
  end
end
