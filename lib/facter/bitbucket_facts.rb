# Fact: bitbucket_builddate, bitbucket_buildnumber, bitbucket_displayname, bitbucket_version
#
# Purpose: Return facts for the running version of bitbucket.
#
require 'json'
require 'open-uri'

# get url of bitbucket
begin
  file = File.open("/etc/bitbucket_url.txt", "rb")
  bitbucket_url = file.read
rescue
  exit 0
end
begin
  url = 'bitbucket_url'
  info = open(url, &:read)
rescue
  exit 0
end
pinfo = JSON.load(info)
pinfo.each do |key, value|
  actual_value = value
  if value.is_a? Array
     actual_value = value.join(',')
  end
  puts "bitbucket_#{key.chomp()}=#{actual_value.chomp}"
end