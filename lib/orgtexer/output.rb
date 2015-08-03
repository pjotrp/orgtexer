module ORGTeXer
  module Output

    def Output::generate(blocks)
      blocks.each do | block |
        print block.join("\n")
        print "\n\n"
      end
    end

  end
end

