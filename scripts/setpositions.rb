require_relative '../models'
require 'pp'

# Set position and elected for each candidacy

Election.all.each do |election|
  election.body.districts.each do |district|
    cands = Candidacy.all(:conditions => { :district_id => district.id, :election_id => election.id }, :order => [:votes.desc])
    pp cands
    puts
    pos = 1
    cands.each do |cand|
      pos <= district.seats ? seats = 1 : seats = 0
      print cand.candidate.surname, ' ', cand.votes, ' ', pos, ' ', seats, "\n"
      cand.position = pos
      cand.seats = seats
      cand.save
      pos += 1
    end
  end
end