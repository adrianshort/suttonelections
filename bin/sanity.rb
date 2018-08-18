require_relative "../models"

# We should be checking polls.seats not districts.seats
@res = repository(:default).adapter.select("
  SELECT    c.election_id,
            c.district_id,
            c.party_id,
            COUNT(c.*) AS qty_candidacies

  FROM      candidacies c,
            districts d

  WHERE     c.district_id = d.id

  GROUP BY  c.election_id,
            c.district_id,
            c.party_id,
            d.seats

  HAVING    COUNT(c.*) > d.seats
")

if @res.size > 0
  puts "ERROR: %d districts have too many candidates standing for one party" % @res.size
  exit 1
else
  puts "OK: All districts have no more candidates standing per party than there are seats."
  exit 0
end
