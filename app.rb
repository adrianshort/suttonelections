require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'

get '/' do
  @wards = %w{ Cheam Sutton Stonecot }
  haml :home
end

get '/wards' do
  @postcode = params[:postcode].strip.upcase

  url = "http://www.uk-postcodes.com/postcode/" + @postcode.gsub(/ /, '') + '.json'

  result = RestClient.get(url)
  result_ary = JSON.parse(result)
  @district_name = result_ary['administrative']['district']['title']
  @ward_name = result_ary['administrative']['ward']['title']
  haml :wards
end

__END__

@@layout
!!!
%html
  %head
    %title Find My Candidates
    %body
      #main
        %h1 Find My Candidates
        = yield
      #footer
        %hr/
        %p Design by Adrian Short
        
@@home
%form{ :method => 'get', :action => '/wards' }
  %label{ :for => "postcode" }
    Postcode
  %input{ :type => 'text', :name => 'postcode', :size => 10 }
  %input{ :type => 'submit', :value => "Find" }
- for ward in @wards
  %p= ward  
  
  
@@wards
%h2
  #{@ward_name} Ward in #{@district_name}
%p
  Your postcode is #{@postcode}
  