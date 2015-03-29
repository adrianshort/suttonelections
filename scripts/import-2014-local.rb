# load 2014 council results

require './models'
require 'csv'
require 'pp'

DataMapper::Model.raise_on_save_failure = true

@found = 0

CSV.foreach(ARGV.shift, :headers => true) do |row|
  begin
    
    if @candidate = Candidate.first(:forenames => row['Forenames'], :surname => row['Surname'])    
      @found += 1
      @ccy = @candidate.candidacies.last
      if @ccy.election_id == 8
        @ccy.votes = row['Votes']
        @ccy.save
      end
      # pp @ccy
    end
    # pp @candidate

    # @p = PollingStation.create(
    #   :id =>        row['District'].strip,
    #   :easting =>  row['Eastings'],
    #   :northing => row['Northings'],
    #   :lat =>       row['lat'],
    #   :lng =>       row['lng']
    # )
  
    # @p.save
  rescue
    pp @p
    # puts p.errors
  end
end

puts @found
