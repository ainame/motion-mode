module Motion
  class CodeConverter
    attr_accessor :s

    def initialize(code)
      @s = code
    end

    class << self
      def arrange_multilines(match_obj)
        if match_obj[2] == '}' && !match_obj[1].include?('{')
          return match_obj[0]
        elsif match_obj[2] == ']'
          return match_obj[0]
        else
          return sprintf("%s%s ", match_obj[1], match_obj[2])
        end
      end

      def characters_to_mark(match_obj)
        replaced_string = match_obj[1].gsub(/\s/, '__SPACE__')
        replaced_string.gsub!(/,/, '__COMMA__')
        replaced_string.gsub!(/:/, '__SEMICOLON__')
        replaced_string
      end

      def convert_block_args(args)
        return '' unless args
        replaced_string = args.gsub(/^\(\s*(.*)\s*\)/, '\1')
        replaced_args = replaced_string.split(',').map do |arg|
          arg.gsub(/\s*[a-zA-Z_0-9]+\s*\*?\s*(\S+)\s*/, '\1')
        end
        replaced_args.size > 1 ? '|' + replaced_args.join(',') + '|' : replaced_args[0]
      end

      def convert_method_args(args)
        return '' unless args
        args.gsub(/\s+(\w+):\s*\([^\)]+\)\s*(\w+)/, ', \1: \2')
      end

      def convert_args(match_obj)
        # Consider args with colon followed by spaces
        following_args = match_obj[2].gsub(/([^:]+)(\s+)(\S+):/, '\1,\3:')
        # Clear extra spaces after colons
        following_args.gsub!(/:\s+/, ':')
        sprintf "%s(%s)", match_obj[1], following_args
      end

      def convert_block_with_args(match_obj)
        args = self.convert_block_args(match_obj[1])
        sprintf("->%s{%s}", args, match_obj[2])
      end

      def convert_method_with_args(match_obj)
        args = self.convert_method_args(match_obj[4])
        if match_obj[2].nil?
          sprintf("def %s {", match_obj[1])
        else
          sprintf("def %s(%s%s) {", match_obj[1], match_obj[3], args)
        end
      end

      def ruby_style_code(match_obj)
        msg = match_obj[2].gsub(/([^:]+)\:\s*(.+)/) do |match|
          self.convert_args(Regexp.last_match)
        end
        sprintf "%s.%s", match_obj[1], msg
      end
    end

    def result
      multilines_to_one_line
      replace_nsstring
      mark_spaces_in_string
      convert_methods
      convert_blocks
      convert_square_brackets_expression
      convert_yes_no_to_true_false
      remove_semicolon_at_the_end
      remove_autorelease
      remove_type_declaration
      remove_float_declaration
      tidy_up
      restore_characters_in_string
      @s
    end

    def multilines_to_one_line
      # Remove trailing white space first. Refs: TrimTrailingWhiteSpace
      @s.gsub!(/[\t ]+$/, '')
      @s.gsub!(/(.*)([^;\s{])$\n^\s*/) do |matchs|
        self.class.arrange_multilines(Regexp.last_match)
      end
      self
    end

    def mark_spaces_in_string
      @s.gsub!(/("(?:[^\\"]|\\.)*")/) do |match|
        self.class.characters_to_mark(Regexp.last_match)
      end
      self
    end

    def convert_methods
      @s.gsub!(/-\s*\([^\)]+\)(\w+)(:\s*\([^\)]+\)\s*(\w+))?((\s+\w+:\s*\([^\)]+\)\s*\w+)*)\s*\{/) do |match|
        self.class.convert_method_with_args(Regexp.last_match)
      end
      self
    end

    def convert_blocks
      @s.gsub!(/\^\s*(\([^\)]+\))?\s*\{([^\}]+)\}/) do |match|
        self.class.convert_block_with_args(Regexp.last_match)
      end
      self
    end

    def convert_yes_no_to_true_false
      @s.gsub!(/([^a-zA-Z0-9]*)YES([^a-zA-Z0-9]*)/) do |match|
        "#{$1}true#{$2}"
      end
      @s.gsub!(/([^a-zA-Z0-9]*)NO([^a-zA-Z0-9]*)/) do |match|
        "#{$1}false#{$2}"
      end
    end

    def convert_square_brackets_expression
      max_attempt = 10 # Avoid infinite loops
      square_pattern = Regexp.compile(/\[([^\[\]]+?)\s+([^\[\]]+?)\]/)

      max_attempt.times do
        if square_pattern.match(@s)
          @s.gsub!(square_pattern) do|match|
            self.class.ruby_style_code(Regexp.last_match)
          end
        else
          break
        end
      end
      self
    end

    def replace_nsstring
      @s.gsub!(/@("(?:[^\\"]|\\.)*")/, '\1')
      self
    end

    def remove_semicolon_at_the_end
      @s.gsub!(/;/, '')
      self
    end

    def remove_autorelease
      @s.gsub!(/\.autorelease/, '')
      self
    end

    def remove_type_declaration
      @s.gsub!(/^(\s*)[a-zA-Z_0-9]+\s*\*\s*([^=]+)=/, '\1\2=')
      self
    end

    def remove_float_declaration
      @s.gsub!(/(\d+\.\d)(f)/, '\1')
      self
    end

    def tidy_up
      # convert arguments separated by ','
      @s.gsub!(/,([a-zA-Z_0-9]+):/, ', \1:')
      # convert block
      @s.gsub!(/:->\{([^\}]+)\}/, ': -> {\1}')
      # convert block with one args
      @s.gsub!(/:->([a-zA-Z_0-9]+)\{([^\}]+)\}/, ': -> \1 {\2}')
      self
    end

    def restore_characters_in_string
      @s.gsub!(/__SPACE__/, ' ')
      @s.gsub!(/__COMMA__/, ',')
      @s.gsub!(/__SEMICOLON__/, ':')
      @s.gsub!(/__YES__/, 'true')
      @s.gsub!(/__NOT__/, 'false')
      self
    end
  end
end
