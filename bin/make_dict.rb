begin
  require 'active_support/core_ext/string'
rescue LoadError
  puts 'missing activesupport. please `gem install activesupport`'
  exit 1
end

$spaces = /[\t ]*/
$word = /[a-zA-Z0-9][_a-zA-Z0-9]*/
$type = /\((#{$spaces}#{$word}){1,3}#{$spaces}\**#{$spaces}\)/
$return_type = /#{$type}?/
$function_name = /#{$word}/
$param_type = /#{$type}/
$param_name = /#{$word}/
$param = /(#{$function_name})(#{$spaces}:#{$spaces}(#{$param_type})#{$spaces}(#{$param_name}))*/
$function = /^[+-]#{$spaces}#{$return_type}#{$spaces}((#{$param}#{$spaces})+)/ 

def extract_symbols(definition)
  result = []
  definition.scan($param).each do |param_match|

    if param_match.compact.size == 1
      result << param_match[0]
    elsif result.empty?
      result << param_match[0]
      # MacRuby or RubyMotion can accept lowercamel variable name
      result << param_match[4].camelize(:lower)
    else
      result << "#{param_match[0].camelize(:lower)}:#{param_match[4].camelize(:lower)}"
    end
  end

  result
end

dict = {}
ARGV.each do|f|
  basename = File.basename(File.expand_path(f), ".h")
  puts "Processing #{basename}.h"

  open(File.expand_path(f), 'r').each do |line|
    function_match = $function.match(
      line.force_encoding("UTF-8").encode(
        "UTF-16BE", :invalid => :replace,
        :undef => :replace, :replace => '?'
      ).encode("UTF-8")
    )

    if function_match
      dict[basename] = 1
      symbols = extract_symbols(function_match[2])
      symbols.each do |symbol|
        dict[symbol] = 1
      end
    else
      bool = /viewDidLoad/.match(
        line.force_encoding("UTF-8").
        encode(
          "UTF-16BE", :invalid => :replace,
          :undef => :replace, :replace => '?'
        ).encode("UTF-8")
      )
      if bool
        p line
      end
    end
  end
end

File.open('motion-mode', 'w+') do |f|
  dict.keys.each do |key|
    f.puts key
  end
end
