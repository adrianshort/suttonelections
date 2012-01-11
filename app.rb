require 'rubygems'
require 'sinatra'
require 'haml'
require './models'

class String
  def pluralize(num)
    if num == 1
      return self
    end
    
    case self[-1]
      when 'y'
        self[0..-2] + 'ies'
      when 's'    
        self + "es"
      else
        self + "s"
    end
  end
end

helpers do

  # Format a number with commas for every ^3
  def commify(num)
    num.to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/,'\1,').reverse
  end
    
  # From http://snippets.dzone.com/posts/show/593
  def to_ordinal(num)
    num = num.to_i
    if (10...20) === num
      "#{num}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = num.to_s
      c = a[-1..-1].to_i
      a + g[c]
    end
  end

  def format_percent(num)
    sprintf("%.1f%%", num)
  end

  def short_date(d)
    d.strftime("%e %b %Y")
  end

  def long_date(d)
    d.strftime("%e %B %Y")
  end

end

get '/' do
#   if params[:postcode]
#     @postcode = params[:postcode].strip.upcase
# 
#     unless result = Postcode.finder(@postcode)
#       # Invalid postcode
#       redirect '/error'
#     end
#   
#     # Postcode valid but not in LB Sutton
#     if result.district_code != "00BF"
#       redirect '/aliens'
#     end
#     
#     # Postcode in LB Sutton
#     @ward = Ward.first( :ons_id => result.ward_code )
#     redirect "/wards/#{@ward.slug}/postcode/#{@postcode}"
#   end
  
  @future_elections = Election.future
  @past_elections = Election.past
  haml :index
end

get '/bodies/:body/elections/:date' do
  @election = Election.first(:body => Body.first(:slug => params[:body]), :d => params[:date])
  @total_seats =  Candidacy.sum(:seats, :election => @election)
  @total_votes = Candidacy.sum(:votes, :election => @election)

  # There's got to be a better way to do this, either with SQL or Datamapper
  @total_districts = repository(:default).adapter.select("
    SELECT district_id
    FROM candidacies
    WHERE election_id = #{@election.id}
    GROUP BY district_id
    ORDER BY district_id
  ").count

  @results_by_party = repository(:default).adapter.select("
    SELECT
      p.colour,
      p.name,
      SUM(c.votes) AS votez,
      SUM(c.seats) AS seatz,
      COUNT(*) AS cands

    FROM candidacies c

    LEFT JOIN parties p ON p.id = c.party_id

    WHERE c.election_id = #{@election.id}

    GROUP BY c.party_id, p.colour, p.name

    ORDER BY seatz DESC, votez DESC
  ")

  @results_by_district = repository(:default).adapter.select("
    SELECT
      d.name,
      d.slug AS district_slug,
      SUM(c.seats) AS seats,
      SUM(c.votes) AS votez
      
    FROM districts d, candidacies c

    WHERE
      c.district_id = d.id
      AND c.election_id = #{@election.id}

    GROUP BY c.district_id, d.name, d.slug

    ORDER BY d.name
  ")
  
  haml :electionsummary
end

# get '/bodies/:body/elections/:date/parties/:party' do
#   Not written yet. Show how this party did at this election.
# end

get '/bodies/?' do
  @bodies = Body.all
  haml :bodies
end

get '/bodies/:body/?' do
  @body = Body.first(:slug => params[:body])
  @elections = Election.all(:body => @body, :order => [:d.desc])
  @districts = District.all(:body => @body, :order => [:name])
  haml :body
end

# get '/wards/:slug/postcode/:postcode/?' do
#   @ward = Ward.first(:slug => params[:slug])
#   @postcode = params[:postcode]
#   haml :wards
# end

get '/candidates/:id/?' do
  if @candidate = Candidate.get(params[:id])
    haml :candidate
  else
    404
  end
end

get '/candidates/?' do
  @candidates = Candidate.all(:order => [ :surname, :forenames ])
  haml :candidates
end

get '/bodies/:body/elections/:date/:districts_name/:district' do
  @district =     District.first(:slug => params[:district])
  @body =         Body.first(:slug => params[:body])
  @election =     Election.first(:body => @body, :d => params[:date])
  @candidacies =  Candidacy.all(:district => @district, :election => @election, :order => [:votes.desc])
  @total_votes =  Candidacy.sum(:votes, :district => @district, :election => @election)
  @districts_in_this_election = @election.candidacies.districts
  haml :resultsdistrict
end

get '/bodies/:body/:districts_name/:district' do
  @district =     District.first(:slug => params[:district])
  @body =         Body.first(:slug => params[:body])
  haml :district
end

get '/how-the-council-election-works' do
  haml :election
end

get '/how-the-parliament-election-works' do
  haml :parliament
end

# get '/voting' do
#   haml :voting
# end

get '/error' do
  haml :error
end

get '/about' do
  haml :about
end

# get '/aliens' do
#   haml :aliens
# end

not_found do
  haml :not_found
end
