require 'rubygems'
require 'sinatra'
require 'haml'
require './models'
require 'rack-flash'

set :root, File.dirname(__FILE__)
enable :sessions
use Rack::Flash

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
    sprintf("%.0f%%", num)
  end

  def short_date(d)
    d.strftime("%e %b %Y")
  end

  def long_date(d)
    d.strftime("%e %B %Y")
  end

  # Exception for Labour/Co-operative candidacies
  def party_name(labcoop, party_name)
    labcoop ? "Labour and Co-operative Party" : party_name
  end

end

get '/' do
  @election = Election.get(9) # FIXME magic number
  @election_title = "#{@election.body.name} #{@election.kind} #{long_date(@election.d)}"

  if params[:postcode]
    if @p = Postcode.get(params[:postcode].strip.upcase)
      # Postcode is valid and in LB Sutton

      if @election.body.district_name == 'constituency'
        @district = District.get(@p.constituency_id)
      else
        @district = District.get(@p.ward_id)
      end

      flash[:notice] = "Postcode <strong>#{@postcode}</strong> is in #{@district.name} #{@election.body.district_name}"

      if @p.polling_station
        @ps_postcode = Postcode.get(@p.polling_station.postcode)
        @polling_station = "Your polling station is \
          <a href=\"http://www.openstreetmap.org/?mlat=%s&mlon=%s&zoom=16\">%s, %s, %s</a>" \
          % [ @ps_postcode.lat, @ps_postcode.lng, @p.polling_station.name, \
            @p.polling_station.address, @p.polling_station.postcode]
      end

      redirect "/bodies/#{@election.body.slug}/elections/#{@election.d}/#{@election.body.districts_name}/#{@district.slug}"
    else
      flash.now[:error] = "<strong>#{@postcode}</strong> is not a postcode in Sutton"
    end
  end

  # Display a random postcode as default search term
  @random_pc = repository(:default).adapter.select("
    SELECT postcode
    FROM postcodes
    ORDER BY RANDOM()
    LIMIT 1
  ")

  @default_pc = @random_pc[0]

  @future_elections = Election.future
  @past_elections = Election.past
  haml :index
end

get '/bodies/:body/elections/:date' do
  @body = Body.first(:slug => params[:body])
  @election = Election.first(:body => @body, :d => params[:date])
  @elections_for_this_body = Election.all(:body => @body, :order => [:d])
  @total_seats =  Candidacy.sum(:seats, :election => @election)
  @total_votes = Candidacy.sum(:votes, :election => @election)

  # There's got to be a better way to do this, either with SQL or Datamapper
  @total_districts = repository(:default).adapter.select("
    SELECT district_id
    FROM candidacies
    WHERE election_id = ?
    GROUP BY district_id
    ORDER BY district_id
  ", @election.id).count

  @results_by_party = repository(:default).adapter.select("
    SELECT
      p.colour,
      p.name,
      SUM(c.votes) AS votez,
      SUM(c.seats) AS seatz,
      COUNT(*) AS cands

    FROM candidacies c

    LEFT JOIN parties p ON p.id = c.party_id

    WHERE c.election_id = ?

    GROUP BY c.party_id, p.colour, p.name

    ORDER BY seatz DESC, votez DESC
  ", @election.id)

  @results_by_district = repository(:default).adapter.select("
    SELECT
      d.name,
      d.slug AS district_slug,
      SUM(c.seats) AS seats,
      SUM(c.votes) AS votez,
      COUNT(c.id) AS num_candidates

    FROM districts d, candidacies c

    WHERE
      c.district_id = d.id
      AND c.election_id = ?

    GROUP BY c.district_id, d.name, d.slug

    ORDER BY d.name
  ", @election.id)

  # For elections that haven't yet been held
  @districts_in_this_election = repository(:default).adapter.select("
    SELECT DISTINCT d.name, d.slug

    FROM candidacies c
    LEFT JOIN districts d
    ON c.district_id = d.id

    WHERE c.election_id = ?

    ORDER BY d.name
  ", @election.id)
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
  @districts = District.all(:body => @body, :order => [:name])
  
  @elections = repository(:default).adapter.select("
    SELECT
      e.id,
      e.kind,
      e.d,
      SUM(p.ballot_papers_issued)::float / SUM(p.electorate) * 100 AS turnout_percent
    
    FROM elections e
    
    LEFT JOIN polls p
    ON e.id = p.election_id 

    WHERE e.body_id = ?

    GROUP BY p.election_id, e.id
    ORDER BY e.d DESC
  ", @body.id)
  
  haml :body
end

# get '/wards/:slug/postcode/:postcode/?' do
#   @ward = Ward.first(:slug => params[:slug])
#   @postcode = params[:postcode]
#   haml :wards
# end

get '/candidates/:id/?' do
  if @deleted_candidate = DeletedCandidate.get(params[:id])
    redirect "/candidates/#{@deleted_candidate.candidate_id}", 302 # HTTP 302 Moved Temporarily
  end

  if @candidate = Candidate.get(params[:id])
    @candidacies = repository(:default).adapter.select("
      SELECT
        e.d,
        c.*,
        p.name AS party_name,
        p.colour AS party_colour,
        b.name AS body_name,
        b.slug AS body_slug,
        b.districts_name AS districts_name,
        d.name AS district_name,
        d.slug AS district_slug

      FROM candidacies c

      INNER JOIN elections e
      ON c.election_id = e.id

      INNER JOIN parties p
      ON c.party_id = p.id

      INNER JOIN bodies b
      ON e.body_id = b.id

      INNER JOIN districts d
      ON c.district_id = d.id

      WHERE c.candidate_id = ?

      ORDER BY d
    ", @candidate.id)

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
  @total_candidates =  Candidacy.count(:district => @district, :election => @election)
  @total_seats =  Candidacy.sum(:seats, :district => @district, :election => @election)
  @districts_in_this_election = @election.candidacies.districts
  @poll =         Poll.get(@district.id, @election.id)

  if @total_seats == 1
    @share_denominator = @total_votes
  elsif @poll && @poll.valid_ballot_papers
    @share_denominator = @poll.valid_ballot_papers
  else
    @share_denominator = @total_votes / @total_seats
    @share_message = "The vote share percentages have been estimated as we don't have data for the number of valid ballot papers in this poll."
  end

  # Postgres: All the columns selected when using GROUP BY must either be aggregate functions or appear in the GROUP BY clause
  @results_by_party = repository(:default).adapter.select("
    SELECT
      p.name AS party_name,
      p.colour AS party_colour,
      COUNT(c.id) AS num_candidates,
      SUM(c.seats) AS num_seats,
      SUM(c.votes) AS total_votes

    FROM candidacies c

    LEFT JOIN parties p
    ON c.party_id = p.id

    WHERE c.district_id = ?
    AND c.election_id = ?

    GROUP BY p.name, p.colour

    ORDER BY total_votes DESC
  ", @district.id, @election.id)

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

get '/error' do
  haml :error
end

get '/about' do
  haml :about
end

not_found do
  haml :not_found
end
