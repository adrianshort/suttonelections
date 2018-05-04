ward = ''
electorate = ''

ARGF.each do |line|
  if line[0,2] == '# '
    ward = line[2..-1].chomp
  elsif line[0,3] == '## '
    electorate = line[3..-1].chomp
  else
    puts [ ward, line ].join ','
  end
end
