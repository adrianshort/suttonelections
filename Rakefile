require './models'

task default: :elections

desc "List elections"
task :elections do
  puts "%3s %-10s %-20s %6s" % %w( ID Date Body Candidacies)
  #puts "ID  Date       Body            Candidacies"
  Election.each do |e|
    puts "%3d %s %-20s %6d" % [ e.id, e.d, e.body.name, e.candidacies.size ]
  end
end

desc "Set the candidate positions for an election (will prompt you for election ID)."
task :set_positions do
    Election.all.each do |e|
      puts "%d %s %s" % [ e.id, e.d, e.body.name ]
    end

    puts "Which election ID?"

    STDOUT.flush
    id = STDIN.gets.chomp.to_i
    
    if e = Election.get(id)
      puts "%d %s %s" % [ e.id, e.d,e.body.name ]
      e.polls.each do |poll|
        poll.set_positions
        
        separator = '-' * poll.district.name.size
        puts
        puts separator
        puts poll.district.name
        puts separator
        
        ccys = Candidacy.all(:conditions => { :district_id => poll.district_id, :election_id => e.id }, :order => [:votes.desc])

        ccys.each do |cand|
          puts "%-25s %-25s %-40s %5d %2d %s" % [ cand.candidate.surname, cand.candidate.forenames, cand.party.name, cand.votes, cand.position, cand.seats == 1 ? 'elected' : '' ]
        end
      end
    else
      puts "Election ID #{id} not found."
      return 1
    end
end
