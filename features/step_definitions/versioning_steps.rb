require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am logged in as (.*)(?: user)?$/ do |username|
  visit login_path
  fill_in "Username", :with => username
  fill_in "Password",  :with => "password"
  click_button "Login"
end

Given /^I have a (.*) page$/ do |status|
  case status
  when /published/
    @page = pages(:first)
    @page.status.should == Status[:published]
  when /draft/
    @page = pages(:draft)
    @page.status.should == Status[:draft]
  end
end

Given /^I have a (.*) page with a draft$/ do |status|
  Given "I have a #{status} page"
  @page.title = "#{@page.title} Draft"
  @page.status = Status[:draft]
  lambda { @page.save }.should change{ @page.versions.length }.by(1)
  @page.reload
end

When /^I edit the page$/ do
  visit admin_pages_path
  click_link @page.title
  fill_in "Page Title", :with => "Edited"
end

When /^I save it as (?:a )?(draft|published)$/ do |status|
  select status.titleize, :from => "Status"
  click_button "Save"
end

Then /^the content I am editing should be the draft$/ do
  field_labeled("Page Title").value.should =~ /.+ Draft/
end


Then /^the page should be saved$/ do
  @page.current.title.should == "Edited"
end

Then /^not change the live version$/ do
  @page.reload.title.should_not == "Edited"
end

Then /^change the live version$/ do
  @page.reload.title.should == "Edited"
end
