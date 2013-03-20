require 'active_support/core_ext/string'
 
$spaces = /[\t ]*/
$word = /[_a-zA-Z0-9]+/
$type = /\((#{$spaces}#{$word}){1,3}#{$spaces}\**#{$spaces}\)/
$return_type = /#{$type}?/
$function_name = /#{$word}/
$param_type = /#{$type}/
$param_name = /#{$word}/
$param = /(#{$function_name})#{$spaces}:#{$spaces}(#{$param_type})#{$spaces}(#{$param_name})/
$function = /#{$spaces}[+-]#{$spaces}#{$return_type}#{$spaces}((#{$param}#{$spaces})+)/ 

def extract_symbols(definition)
  result = []

  definition.scan($param).each do |param_match|
    # MacRuby or RubyMotion can accept lowercamel variable name
    if result.empty?
      result << param_match[0]
      result << param_match[3].camelize(:lower)
    else
      result << "#{param_match[0].camelize(:lower)}:#{param_match[3].camelize(:lower)}"
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
    end    
  end

end

File.open('motion-mode', 'w+') do |f|
  dict.keys.each do |key|
    f.puts key
  end
end
