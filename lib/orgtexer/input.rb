module ORGTeXer
  module Input

    # Remove all lines that start with # or % followed by a space 
    def Input::remove_comments(blocks)
      blocks.map { |block|
        block.delete_if { |line|
          line =~ /^(#|%)+\s/
        }
      }
    end

    def Input::remove_empty_blocks(blocks)
      blocks.delete_if { |block| block == [] }
    end

    def Input::process(blocks)
      remove_comments(blocks)
      remove_empty_blocks(blocks)
      blocks
    end

  end
end
