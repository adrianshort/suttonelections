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
    %link{ :rel => 'stylesheet', :type => 'text/css', :href => 'style.css' }
    %body
      #header
        %h1 Find My Candidates
      #main
        = yield
      #footer
        %hr/
        %p
          Made by 
          %a{ :href => "http://adrianshort.co.uk/" } Adrian Short
          with
          %a{ :href => "http://www.ordnancesurvey.co.uk/oswebsite/products/code-point-open/" } Ordnance Survey
          and
          %a{ :href => "http://www.sutton.gov.uk/" } Sutton Council 
          data,
          %a{ :href => "http://uk-postcodes.com" } UK Postcodes API
          and
          %a{ :href => "http://sinatrarb.com" } Sinatra.
        %p
          Hosted by 
          %a{ :href => "http://heroku.com" } Heroku.
          Source at 
          %a{ :href => "http://github.com/adrianshort" } Github.

        
@@home
%form{ :method => 'get', :action => '/wards' }
  %label{ :for => "postcode" } Postcode
  %input{ :type => 'text', :name => 'postcode', :size => 8, :maxlength => 8 }
  %input{ :type => 'submit', :value => "Find" }
- for ward in @wards
  %p= ward  
  
  
@@wards
%h2 #{@postcode} is in #{@ward_name} Ward in #{@district_name}
  