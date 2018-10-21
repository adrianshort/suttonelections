# require_relative '../models'
require 'scraperwiki'
require 'sequel'
load '_config.rb'
require 'pp'

class Object
  def to_hash
    h = {}

    instance_variables.each do |var|
      h[var.to_s.delete('@')] = instance_variable_get(var)
    end

    # Remove DataMapper-specific keys, which start with an underscore
    h.keys.each do |k|
      h.delete(k) if k.match(/^_/)
    end
    h
  end
end

DB = Sequel.connect(ENV['DATABASE_URL'])

DB[:polls].each { |o| ScraperWiki.save_sqlite([:district_id, :election_id], o.to_hash, 'polls') }
DB[:candidates].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'candidates') }
DB[:candidacies].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'candidacies') }
DB[:deleted_candidates].each { |o| ScraperWiki.save_sqlite([:old_candidate_id], o.to_hash, 'deleted_candidates') }
DB[:elections].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'elections') }
DB[:districts].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'districts') }
DB[:bodies].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'bodies') }
DB[:parties].each { |o| ScraperWiki.save_sqlite([:id], o.to_hash, 'parties') }
