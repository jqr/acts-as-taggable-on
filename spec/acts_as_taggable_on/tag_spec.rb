require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  before(:each) do
    @tag = Tag.new
    @user = TaggableModel.create(:name => "Pablo")  
  end
  
  it "should require a name" do
    @tag.valid?
    @tag.errors.on(:name).should == "can't be blank"
    @tag.name = "something"
    @tag.valid?
    @tag.errors.on(:name).should be_nil
  end
  
  it "should equal a tag with the same name" do
    @tag.name = "awesome"
    new_tag = Tag.new(:name => "awesome")
    new_tag.should == @tag
  end
  
  it "should return its name when to_s is called" do
    @tag.name = "cool"
    @tag.to_s.should == "cool"
  end
  
  describe "renaming" do
    before(:each) do
      Tag.delete_all
      Tagging.delete_all
      
      @user.tag_list = 'start'
      @user.save!
      @tag = Tag.find_by_name('start')
    end
    
    describe "when the new tag does not exist" do
      it "should modify the tag's name" do
        @tag.rename!('finish')
        Tag.find_by_name('finish').id.should == @tag.id
      end
    end
    
    describe "when the new tag does exist" do
      before(:each) do
        Tag.create(:name => 'finish')
      end
      
      it "should delete the old tag" do
        @tag.rename!('finish')
        Tag.find_all_by_id(@tag.id).should == []
      end
      
      it "should change all references to the new tag" do
        TaggableModel.find_tagged_with('finish').should_not include(@user)
        @tag.rename!('finish')
        TaggableModel.find_tagged_with('finish').should include(@user)
      end
      
      it "should modify all cached references"
    end
  end
end
