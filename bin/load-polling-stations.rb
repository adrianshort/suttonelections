# load polling stations data (polling-stations.csv)

require './models'
require 'csv'
require 'pp'

DataMapper::Model.raise_on_save_failure = true

CSV.foreach(ARGV.shift, :headers => false) do |row|
  begin
    if @p = PollingStation.get(row[1])
      @p.name = row[2]
      @p.address = row[3]
      @p.postcode = row[4]
      @p.save
    else
      puts "#{row[1]} not found"
    end
  rescue
    puts @p.saved?
    pp @p
    @p.errors.each { |r| puts r }
  end
end
