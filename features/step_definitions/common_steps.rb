Given /^a directory at "([^\"]*)"$/ do |path|
  Dir.mkdir(path) unless File.exist? path
end

Given /^no directory at "([^\"]*)"$/ do |path|
  Dir.rmdir(path) if File.exist? path
end

When /^I copy fixture "([^\"]*)" to "([^\"]*)"$/ do |from, to|
  FileUtils.cp_r("spec/fixtures/" + from, to)
end

Then /^I should find file at "([^\"]*)"$/ do |path|
  expect(File.exist?(path)).to be_truthy
end

Then /^I should find no file at "([^\"]*)"$/ do |path|
  expect(File.exist?(path)).to be_falsey
end
