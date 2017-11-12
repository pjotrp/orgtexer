
module FormatBibAuthors

  # Create a list of author names, so it is 'lastname, firstname(s)'
  # See also https://web.archive.org/web/20130620150431/http://amath.colorado.edu/documentation/LaTeX/reference/faq/bibstyles.html
  # There are really two styles:
  # {M{\"o}ller, Steffen and Afgan, Enis and Banck, Michael and Bonnal, Raoul JP and ...}
  # and
  # {{M{\"o}ller, S. and Afgan, E. and Banck, M. and Bonnal, R. J. P. and ...}
  # We also allow for the 'malformed' {Ball MP, Bobe JR, Chou MF} style for authors
  def split_bib_authors list
    authors = []
    if list.kind_of?(String)
      if list =~ / and / or list =~ /\./
        strip_bibtex(list).split(/ and /).each do | s |
          s2 =
            if s !~ /,/
              # No comma!
              first,last = s.split(/\s+/,2)
              if first and not last
                first
              else
                raise 'Problem with bib name containing comma <'+s+'>' if not first and not last
                last + ', '+first
              end
            else
              # Looks like 'Bonnal, R. J. P.' or 'Bonnal, Raoul JP'
              s
            end
          authors.push s2
        end
      else
        # Looks like misformed 'Ball MP'
        strip_bibtex(list).split(/, /).each do | s |
          last,first = s.split(/\s+/,2)
          firsts = first.split(//).join(". ")+"."
          # $stderr.print firsts, "\n"
          authors.push last + ', '+firsts
        end
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
