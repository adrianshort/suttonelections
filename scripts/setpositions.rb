require_relative '../models'
require 'pp'

# Set position and elected for each candidacy
# WARNING - This will only work in full council elections not byelections (as the number of seats being elected in that eleciton is probably less than the total number of seats in the ward)
# This will break all the byelection data currently in the database

election = Election.first(:d => ARGV.shift)

unless election
  puts "Election not found. Usage example: $ %s 2006-05-04" % __FILE__
  exit 1
end

puts "Setting candidacy positions for %s %s %s" % [ election.body.name, election.kind, election.d.to_s ]
if election.candidacies.size < 30
  puts "This script only works for full council elections. Your election looks like a byelection, so quitting."
  exit 1
end
puts "%d candidacies in this election" % election.candidacies.size

election.body.districts.each do |district|
  cands = Candidacy.all(:conditions => { :district_id => district.id, :election_id => election.id }, :order => [:votes.desc])
  # pp cands
  puts
  pos = 1
  cands.each do |cand|
    if pos == 1
      puts "-" * 62
      puts district.name
      puts "-" * 62
    end

    # If this candidate's position was in the top district.seats positions, they won a seat
    pos <= district.seats ? seats = 1 : seats = 0
    puts "%-25s %-25s %5d %2d %d" % [ cand.candidate.surname, cand.candidate.forenames, cand.votes, pos, seats ]
    cand.position = pos
    cand.seats = seats
    cand.save
    pos += 1
  end
end
