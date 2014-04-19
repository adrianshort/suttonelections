# Check whether a list of parties is in the parties table

require_relative '../models'

ARGF.each do |line|
  line.strip!
  print line
  if Party.find(line)
    puts " found"
  else
    puts " not found"    
  end
end
