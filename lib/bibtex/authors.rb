
module FormatBibAuthors

  # Create a list of author names, so it is 'lastname, firstname(s)'
  def split_bib_authors list
    authors = []
    if list.kind_of?(String)
      strip_bibtex(list).split(/ and /).each do | s |
        s2 = 
          if s !~ /,/
            # No comma! 
            first,last = s.split(/\s+/,2)
            if first and not last
              first
            else
              raise 'Problem with bib name <'+s+'>' if not first and not last
              last + ', '+first
            end
          else
            s
          end
        authors.push s2
      end
      authors
    else
      list
    end
  end

  # Split names, according to comma
  def split_first_lastname s
    last,first = s.split(/,/,2)
    first = '' if first == nil
    return first,last.capitalize
  end

  # Shorten first name, e.g. 'Mark Elias' becomes 'M. E.'
  def to_initials s
    names = s.strip.split(/\.?\s+/)
    res = names.map { | n | n[0..0] }.join('. ')
    # $stderr.print res,"\n"
    res
  end
end


