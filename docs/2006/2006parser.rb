new_ward = true

ARGF.each do |line|
    line.chomp!
    
    if line == ''
        new_ward = true
        next
    end
    
    if new_ward
        @ward_name = line[0..28].strip
        new_ward = false
    end
    
    data = []
    data << @ward_name
    data << line[29..-1].split(/\s{2,}/)
    
    puts data.join "\t"   
end
