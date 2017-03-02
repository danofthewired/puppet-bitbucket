# Fact: bitbucket_builddate, bitbucket_buildnumber, bitbucket_displayname, bitbucket_version
#
# Purpose: Return facts for the running version of bitbucket.
#
require 'json'
require 'open-uri'

# variables
bitbucket_version_var = '0'
file_exists = true
url_read = true

# get url of bitbucket
if File.exist? '/etc/bitbucket_url.txt'
    begin
      file = File.open("/etc/bitbucket_url.txt", "rb")
      bitbucket_url = file.read
    rescue
      file_exists = false
    end
end

if file_exists
    begin
      url = 'bitbucket_url'
      info = open(url, &:read)
    rescue
      url_read = false
    end
end

if url_read
    pinfo = JSON.load(info)
    pinfo.each do |key, value|
      actual_value = value
      if value.is_a? Array
	 actual_value = value.join(',')
      end
      #puts "bitbucket_#{key.chomp()}=#{actual_value.chomp}"
      bitbucket_version_var = "bitbucket_#{key.chomp()}=#{actual_value.chomp}"
    end
end

Facter.add(:bitbucket_version) do
  setcode do
    bitbucket_version_var
  end
end