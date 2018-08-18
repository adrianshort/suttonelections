# Convert ModernGov XML file to CSV
# eg https://moderngov.sutton.gov.uk/mgWebService.asmx/GetElectionResults?lElectionId=15
# The full API docs are at: https://moderngov.sutton.gov.uk/mgWebService.asmx

require 'nokogiri'
require 'csv'
require 'pp'

doc = File.open(ARGV.shift) { |f| Nokogiri::XML(f) }

csv_string = CSV.generate do |csv|
  doc.search('candidates candidate').each do |cand|
    row = []
    row << cand.at('areatitle').inner_text
    row << cand.at('candidatename').inner_text
    row << cand.at('politicalpartytitle').inner_text
    row << cand.at('numvotes').inner_text.to_i
    row << cand.at('iselected').inner_text
    csv << row
  end
end

puts csv_string
