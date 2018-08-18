require_relative '../models'
require 'csv'
require 'pp'
# $ ruby scripts/import-candidates-csv.rb [ELECTION ID] [CSV FILENAME]

# Import a CSV file of election candidates for a specified election
# The election for which you're importing data must already exist in the elections table

@election = Election.get(ARGV.shift)
pp @election

candidates_matched = 0

CSV.foreach(ARGV.shift) do |line|
  # pp line

  district_name, candidate_surname, candidate_forenames, party = line

  # District
  @district = District.first(:name => district_name)

  # pp @district

  # Candidate
  @candidate = Candidate.first_or_create(:forenames => candidate_forenames, :surname => candidate_surname)
  
  if @candidate
    pp @candidate
    candidates_matched += 1
  end

  unless @candidate.saved?
    $stderr.puts "Couldn't save candidate #{@candidate}"
    exit 1
  end
  
  # Party
  @party = Party.first_or_create(:name => party)
  
  puts @party.name
  unless @party.saved?
    $stderr.puts "Couldn't save party #{@party}"
    exit 1
  end
  
  # Candidacy
  @candidacy = Candidacy.create(
    :election =>  @election,
    :candidate => @candidate,
    :party =>     @party,
    :district =>  @district,
    :votes =>     nil
  )

  unless @candidacy.saved?
    $stderr.puts "Couldn't save candidacy #{@candidacy}"
    exit 1
  end
  
end

puts "Candidates: #{Candidate.count}"
puts "Candidacies: #{Candidacy.count}"
puts candidates_matched

