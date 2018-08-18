require_relative '../models'
require 'pp'
# $ ruby scripts/import-results-tsv.rb [ELECTION ID] [TSV FILENAME]

# Import a TSV file of election results for a specified election
# The election for which you're importing data must already exist in the elections table

# Run setpositions.rb after this importer to set candidacies.position and candidacies.elected

@election = Election.get(ARGV.shift)

ARGF.each do |line|
  district_name, candidate_name, party, votes, elected = line.split("\t").map{ |e| e.strip }

  # District
  @district = District.first(:name => district_name)

  # Candidate
  # Assumes that the candidate name is written "forename surname"
#   bits = candidate_name.split(" ")
#   candidate_forenames = bits[0..-2].join(" ")
#   candidate_surname = bits.last

  # Assumes that the candidate name is written "surname, forename(s)"
  bits = candidate_name.split(", ")
  candidate_forenames = bits[1]
  candidate_surname = bits[0]
  
  @candidate = Candidate.first_or_create(:forenames => candidate_forenames, :surname => candidate_surname)
  
  pp @candidate
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
    :votes =>     votes
  )

  unless @candidacy.saved?
    $stderr.puts "Couldn't save candidacy #{@candidacy}"
    exit 1
  end
  
end
