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

    # Preprocess input that does some simple (line) transformations
    def Input::preprocess(blocks)
      remove_comments(blocks)
      remove_empty_blocks(blocks)
    end

    module Org
      def Org::titles_to_wtex(blocks)
        blocks.map { |block|
          block.map { |line|
            if line =~ /^(\*+)/
              replacewith = '='*$1.size
              replacewith + ' ' + $' + ' ' + replacewith
            else
              line
            end
          }
        }
      end
      
      def Org::process(blocks)
        blocks
      end
    end
    
  end
end
