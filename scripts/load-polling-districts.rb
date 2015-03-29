# load polling districts data

require './models'
require 'csv'
require 'pp'

DataMapper::Model.raise_on_save_failure = true
PollingStation.destroy

CSV.foreach(ARGV.shift, :headers => true) do |row|
  begin
    @p = PollingStation.create(
      :id =>        row['District'].strip,
      :easting =>  row['Eastings'],
      :northing => row['Northings'],
      :lat =>       row['lat'],
      :lng =>       row['lng']
    )
  
    @p.save
  rescue
    pp @p
    # puts p.errors
  end
end
