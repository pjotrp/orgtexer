
require 'bibtex/authors'

module BibFormatter

  def BibFormatter::get_formatter writer, style
    case style[:format]
      when :nrg
        BibNRGFormatter.new(writer, style)
      when :springer
        BibSpringerFormatter.new(writer, style)
      else
        BibDefaultFormatter.new(writer, style)
    end
  end
end

class BibAuthor
  attr_accessor :surname, :initials
  def initialize name
    @surname = name
  end

  def to_s
    @surname
  end
end

module BibOutput

  include FormatBibAuthors

  # Authors in bibtex style are separated by 'and' keywords. Valid
  # names are
  #
  #   Jane Austen
  #   J. Austen
  #   Austen, Jane
  #   Austen, J.
  #
  # The output style can be any of these: firstnamefirst, initialsfirst,
  # firstnamelast, initialslast.
  #
  def authors authorlist, style = {}
    authors = split_bib_authors(authorlist)
    num = authors.size
    max=5
    max=style[:max_authors] if style[:max_authors]
    if style[:etal] and num > max
      aunum = 1
      aunum = style[:etal_num] if style[:etal_num]
      text = comma(authors[0..aunum-1].join(', '))
      text = text.chop.chop
      text += if style[:etal] == :plain
        ' et al.'
      else
        ' <i>et al.</i>'
      end

    else
      if num > 1
        # p [num,authors]
        text = comma(authors[0..num-2].join(', ')+' &amp; '+authors[num-1])
      else
        text = comma(authors[0])
      end
      # strip final comma
      text = text.chop.chop
    end
    text
  end

  def url doi, link, full = false
    if doi and doi != ''
      text = '[DOI]'
      text = 'doi:'+doi if full
      " <a href=\"http://dx.doi.org/#{doi}\">#{text}</a>"
    elsif link and link != ''
      text = '[Link]'
      text = link if full
      " <a href=\"#{link}\">#{text}</a>"
    else
      ''
    end
  end

  def citations bib
    text = ''
    if @style[:bib_cites]
      if bib.has?(:Impact)
        text += "Impact factor = #{bold(bib[:Impact])}"
      end
      cited = ''
      if bib.has?(:Cited)
        cited += " #{bold(bib[:Cited])}x,"
      end
      if bib.has?(:Pmcited)
        cited += " Pubmed #{bold(bib[:Pmcited])}x,"
      end
      if bib.has?(:Gscited)
        cited += " Google Scholar #{bold(bib[:Gscited])}x,"
      end
      if cited != ''
        text += "Cited "+cited.chop
      end
      text = ' <small>('+text+')</small>' if text != ''
    end
    text
  end

  def strip_bibtex str
    str.gsub!(/\{/,'')
    str.gsub!(/\}/,'')
    # $stderr.print str
    str
  end

  def newline
    '<br />'
  end

  def bold str
    return @writer.bold(str) if str!=nil and str.strip != ''
    ''
  end

  def italic str
    return @writer.italics(str) if str!=nil and str.strip != ''
    ''
  end

  def colon str, space=true
    if str!=nil and str.strip != ''
      c = ''
      c = ' ' if space
      return str.rstrip + ':' + c
    end
    ""
  end

  def prefix_colon str, space=true
    if str!=nil and str.strip != ''
      c = ''
      c = ' ' if space
      return ':' + str.rstrip + c
    end
    ""
  end

  def comma str
    if str!=nil and str.strip != ''
      return str.rstrip + ', '
    end
    ""
  end

  def braces str
    if str!=nil and str.strip != ''
      return '(' + str.strip + ')'
    end
    ""
  end

  def dot str
    if str!=nil and str.strip != ''
      return str.rstrip + '. '
    end
    ""
  end

  def prefix_dot str
    if str!=nil and str.strip != ''
      return '.' + str.rstrip + ' '
    end
    ""
  end

  # Return sentence with only first letter capitalized (except for those
  # between curly braces)
  #
  def capitalize_first str
    str.gsub!(/^\{/,'')
    str.gsub!(/\}$/,'')
    a = str.split(/[{}]/)
    # $stderr.print(a.join('@@'),"\n")
    i = 0
    str2 = a.map { | s |
      i += 1
      if (i % 2 == 1)
        if (i==1)
          s.capitalize
        else
          s.downcase
        end
      else
        s
      end
    }.join('')
    # $stderr.print(str2,"\n")
    str2
  end

  def convert_special_characters s
    s.gsub('\"{o}',"&ouml;").gsub("~","&nbsp;").gsub('\"{u}',"&uuml;").gsub("\`{e}","&egrave;")
  end

  def edition e
    e
  end

  def pages pg
    return '' if pg == nil or pg.strip == ''

    if pg !~ /-/ and pg !~ /:/
      return pg + 'p'
    end
    pg.strip
  end

end

module BibDefaultOutput

  def cite_marker num
    @writer.superscript(num.to_s)
  end

  def reference_marker num
    # @writer.superscript(num.to_s)
    "#{num.to_s}."
  end

  def write bib
    text = authors(bib[:Author],:etal=>true)
    if bib.type == 'book' or bib.type == 'incollection' or bib.type == 'inproceedings' or bib.type == 'conference'
      text += strip_bibtex(comma(italic(bib[:Title])))+comma(bib[:Booktitle])+" #{bib[:Pages]} (#{bib[:Publisher]} #{bib[:Year]})."
    else

      text += comma(strip_bibtex(bib[:Title]))+comma(italic(bib[:Journal]))+comma(bold(bib[:Volume]))+"#{bib[:Pages]} [#{bib[:Year]}]."
    end
    if !@style[:final]
      text += url(bib[:Doi],bib[:Url])
      text += citations(bib)
    end
    text
  end
end

class BibDefaultFormatter
  include BibOutput
  include BibDefaultOutput

  def initialize writer, style
    @writer = writer
    @style = style
  end

end

class BibNRGFormatter
  include BibOutput
  include BibDefaultOutput

  def initialize writer, style
    @writer = writer
    @style = style
  end

  def reference_marker num
    @writer.superscript(num.to_s)
  end

  def write bib
    text = authors(bib[:Author], :etal=>1, :amp=>true)
    if bib.type == 'book' or bib.type == 'incollection' or bib.type == 'inproceedings'
      text += strip_bibtex(comma(italic(bib[:Title])))+comma(bib[:Booktitle])+comma(bib[:Publisher])+bib[:Pages]+" (#{bib[:Year]})."
    else

      text += comma(strip_bibtex(bib[:Title]))+comma(italic(bib[:Journal]))+comma(bold(bib[:Volume]))+"#{bib[:Pages]} (#{bib[:Year]})."
    end
    if !@style[:final]
      text += url(bib[:Doi],bib[:Url])
      text += citations(bib)
    end
    text
  end
end

class BibSpringerFormatter
  include BibOutput
  include BibDefaultOutput

  def initialize writer, style
    @writer = writer
    @style = style
    style[:max_authors] ||= 3
  end

  def cite_marker num
    @writer.bold(@writer.italics("(#{num.to_s})"))
  end

  def write bib
    text = authors(to_authorlist(bib[:Author]), :etal=>:plain, :etal_num => 3, :amp=>true)
    text += braces(bib[:Year])+' '
    if bib.type == 'book' or bib.type == 'incollection' or bib.type == 'inproceedings' or bib.type == 'conference'
      text += strip_bibtex(dot(capitalize_first(bib.required(:Title))))+comma(bib[:Booktitle])+dot(edition(bib[:Edition]))
      if bib.type == 'book'
        text += comma(bib.required(:Publisher))
      else
        text += comma(bib[:Publisher])
      end
      text += comma(bib[:Organization])+dot(pages(bib[:Pages]))
    elsif bib.type == 'journal'
      # Journal article
      text += dot(strip_bibtex(capitalize_first(bib.required(:Title))))+dot(bib.required(:Journal))+colon(bib[:Volume],false)+
              braces(bib[:Number],false)+dot(pages("#{bib.required(:Pages)}"))+'.'
    else
      # this is used mostly:
      text += dot(strip_bibtex(capitalize_first(bib[:Title])))+dot(bib[:Journal])+bib[:Volume]+braces(bib[:Number])+prefix_colon(bib[:Pages],false)+'.'
    end
    if !@style[:final]
      text += url(bib[:Doi],bib[:Url],true)
      text += citations(bib)
    end
    text = text.strip
    text = text.chop if text =~ /[,.]$/
    convert_special_characters(text)+newline
  end

  def to_authorlist s
    list = split_bib_authors(s)
    list = list.map do | a |
      first,last = split_first_lastname(a)
      if first !~ /\./
        $stderr.print "Possibly malformed first name <#{first.strip}> has no dot in <",a,">\n"
      end
      if first =~ /\w\w/
        $stderr.print "Possibly malformed first name <#{first.strip}> contains two+ letters in ref <",a,">\n"
      end
      a1 = last+' '+to_initials(first)
      a2 = a1.gsub(/[,.]/,' ')
      # $stderr.print a," <--\n"
      a2.strip
    end
    list
  end
end
