module ORGTeXer
  module HTML

    def HTML::generate(blocks)
      blocks.each do | block |
        print "<p>"
        print block.join("\n")
        print "</p>\n"
      end
    end

  end
end
