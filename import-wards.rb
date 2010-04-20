require 'rubygems'
require 'csv'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'lib/models'

# Import wards

CSV::Reader.parse(File.open('wards.csv', 'rb')) do |row|
    p row
    puts Ward.create!(
      'ons_id'  => row[0],
      'name'    => row[1],
      'slug'    => Ward.slugify(row[1]),
      'constituency_id' => row[2] == 'Carshalton and Wallington' ? 1 : 2
    )
    
end