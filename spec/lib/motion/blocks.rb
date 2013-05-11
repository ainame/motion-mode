#       it '' do
#       source = <<S
# [aSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
#     NSLog(@"Object Found: %@", obj);
# } ];
# S
#       expected = <<S
# [aSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
#     NSLog(@"Object Found: %@", obj);
# } ];
# S
#         c = Motion::CodeConverter.new(source)
#         c.multilines_to_one_line.should eq(expected)
#       end
#     end
