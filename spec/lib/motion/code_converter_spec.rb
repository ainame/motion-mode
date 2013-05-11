require 'spec_helper'

describe Motion::CodeConverter do
  describe "#multilines_to_one_line" do
    context "simple case" do
      it 'align format of splited expression by only line feed' do
        source = <<S.chomp
first_line;
second_line
third_line
S
        expected = <<S.chomp
first_line;
second_line third_line
S
        c = Motion::CodeConverter.new(source)
        c.multilines_to_one_line.s.should eq(expected)
      end

      it 'should align format of splited expression by only line feed' do
        source = <<S.chomp
UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Warning"
                                                 message:@"too many alerts"
                                                delegate:nil
S
        expected = 'UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"too many alerts" delegate:nil'
        c = Motion::CodeConverter.new(source)
        c.multilines_to_one_line.s.should eq(expected)
      end

      it 'should trailing white space' do
        source = <<S.chomp
first_line;
second_line   
S
        expected =<<S.chomp
first_line;
second_line
S
        c = Motion::CodeConverter.new(source)
        c.multilines_to_one_line.s.should eq(expected)
      end
    end
  end

  describe "#replace_nsstring" do
    it 'replace NSString' do
      source   = 'NSDictionary *updatedLatte = [responseObject objectForKey:@"latte"];'
      expected = 'NSDictionary *updatedLatte = [responseObject objectForKey:"latte"];'
      c = Motion::CodeConverter.new(source)
      c.replace_nsstring.s.should eq(expected)
    end
  end

  describe "#mark_spaces_in_string" do
    c = Motion::CodeConverter.new(
      %q{": ,"}
    )
    it do
      c.mark_spaces_in_string.s.should eq(
        %q{"__SEMICOLON____SPACE____COMMA__"}
      )
    end
  end

  describe "#convert_blocks" do
    it 'block without args' do
      source   = <<S.chomp
[UIView animateWithDuration:0.2
        animations:^{view.alpha = 0.0;}]
S
      expected = <<S.chomp
[UIView animateWithDuration:0.2 animations:->{view.alpha = 0.0;}]
S
      c = Motion::CodeConverter.new(source)
      c.multilines_to_one_line.convert_blocks.s.should eq(expected)
    end

    it 'block with one args' do
      source   = <<S.chomp
[UIView animateWithDuration:0.2
        animations:^{view.alpha = 0.0;}
        completion:^( BOOL finished ){ [view removeFromSuperview]; }];
S
      expected = <<S.chomp
[UIView animateWithDuration:0.2 animations:->{view.alpha = 0.0;} completion:->finished{ [view removeFromSuperview]; }];
S
      c = Motion::CodeConverter.new(source)
      c.multilines_to_one_line.convert_blocks.s.should eq(expected)
    end

    it 'block with two args' do
      source   = <<S.chomp
[aSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
      NSLog(@"Object Found: %@", obj);
} ];
S
      expected = <<S.chomp
[aSet enumerateObjectsUsingBlock:->|obj,stop|{
      NSLog(@"Object Found: %@", obj);
} ];
S
      c = Motion::CodeConverter.new(source)
      c.multilines_to_one_line.convert_blocks.s.should eq(expected)
    end
  end

  describe "#convert_square_brackets_expression" do
    it 'convert square brackets expression' do
      source   = '[self notifyCreated];'
      expected = 'self.notifyCreated;'
      c = Motion::CodeConverter.new(source)
      c.convert_square_brackets_expression.s.should eq(expected)
    end

    it 'convert square brackets expression with args' do
      source   = '[self updateFromJSON:updatedLatte];'
      expected = 'self.updateFromJSON(updatedLatte);'
      c = Motion::CodeConverter.new(source)
      c.convert_square_brackets_expression.s.should eq(expected)
    end

    it 'convert square brackets expression with multiple args' do
      source   = '[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0] autorelease];'
      expected = 'UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemBookmarks,tag:0).autorelease;'
      c = Motion::CodeConverter.new(source)
      c.convert_square_brackets_expression.s.should eq(expected)
    end
  end

  describe "#remove_semicolon_at_the_end" do
    it 'remove semicolon at the end' do
      source   = '[[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];'
      expected = '[[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      c = Motion::CodeConverter.new(source)
      c.remove_semicolon_at_the_end().s.should eq(expected)
    end
  end

  describe "#remove_autorelease" do
    it 'remove autorelease' do
      source   = '[[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      expected = 'UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)'
      c = Motion::CodeConverter.new(source)
      c.convert_square_brackets_expression.remove_autorelease
      c.s.should eq(expected)
    end
  end

  describe "remove_type_declaration" do
    it 'remove type declaration' do
      source   = 'UIWindow* aWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      expected = 'aWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      c = Motion::CodeConverter.new(source)
      c.remove_type_declaration.s.should eq(expected)
    end

    it 'remove type declaration with lead spaces' do
      source   = '    UIWindow* aWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      expected = '    aWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]'
      c = Motion::CodeConverter.new(source)
      c.remove_type_declaration.s.should eq(expected)
    end
  end

  describe "#tidy_up" do
    it 'tidy args' do
      source   = """UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemBookmarks,tag:0)"""
      expected = """UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemBookmarks, tag:0)"""
      c = Motion::CodeConverter.new(source)
      c.tidy_up().s.should eq(expected)
    end
  end

  describe "#result" do
    it 'tidy args' do
      source   = 'NSLog(@"test,string:")'
      expected = 'NSLog("test,string:")'
      c = Motion::CodeConverter.new(source)
      c.result.should eq(expected)
    end

    it 'tidy args with block' do
      source   = "UIView.animateWithDuration(0.2,animations:->{ view.alpha = 0.0 })"
      expected = "UIView.animateWithDuration(0.2, animations: -> { view.alpha = 0.0 })"
      c = Motion::CodeConverter.new(source)
      c.result.should eq(expected)
    end

    it 'tidy args with one args' do
      source   = <<S.chomp
[UIView animateWithDuration:0.2
        animations:^{ view.alpha = 0.0; }
        completion:^( BOOL finished ){ [view removeFromSuperview]; }];
S
      expected = <<S.chomp
UIView.animateWithDuration(0.2, animations: -> { view.alpha = 0.0 }, completion: -> finished { view.removeFromSuperview })
S
      c = Motion::CodeConverter.new(source)
      c.result.should eq(expected)
    end

  end

end
