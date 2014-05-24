require_relative "../models"

def show_candidate(id)
  c = Candidate.get(id)
  
  template = "%6s\t%50s\t%20s\t%3s"
  
  puts template % [ c.id, c.forenames, c.surname ]
  
  ccy_template = "%20s\t%15s\t%20s\t%20s"
  c.candidacies.each do |ccy|
    puts template % [ ccy.election.body.name, ccy.election.d, ccy.district.name, ccy.party.name]
  end
end

winner = ARGV.shift
loser = ARGV.shift

puts "WINNER"
show_candidate(winner)

puts

puts "LOSER"
show_candidate(loser)

puts "Are you sure you want to merge these two candidates? The loser will be deleted. (Y or N)"

answer = gets.chomp.downcase

unless answer == 'y'
  puts "Aborting. No changes made to the database."
  exit
end

# Transfer all the loser's candidacies to the winner
repository(:default).adapter.select("
  UPDATE candidacies
  SET candidate_id = #{winner}
  WHERE candidate_id = #{loser}
")

# Delete the loser candidate
Candidate.get(loser).destroy

puts "Merge completed. Here is the merged candidate:"
puts
show_candidate(winner)

