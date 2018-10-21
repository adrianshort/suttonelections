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
  # FIXME wtf - because sometimes we're doing raw sql queries and sometimes it's coming through the DataMapper::Resource class
  d = Date.parse(d) unless d.class == Date
  d.strftime("%e %b %Y")
end

def long_date(d)
  # FIXME wtf - because sometimes we're doing raw sql queries and sometimes it's coming through the DataMapper::Resource class
  d = Date.parse(d) unless d.class == Date
  d.strftime("%e %B %Y")
end

# Exception for Labour/Co-operative candidacies
def party_name(labcoop, party_name)
  # puts labcoop.class # FIXME wtf - because sometimes we're doing raw sql queries and sometimes it's coming through the DataMapper::Resource class
  labcoop == 1 || labcoop == '1' ? "Labour and Co-operative Party" : party_name
end
