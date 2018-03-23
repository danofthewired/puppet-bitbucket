# Fact: bitbucket_builddate, bitbucket_buildnumber, bitbucket_displayname, bitbucket_version
#
# Purpose: Return facts for the running version of bitbucket.
#
require 'json'
require 'open-uri'

# variables
file_exists  = true
url_read     = true
version      = '-1'
display_name = '-1'
build_number = '-1'
build_date   = '-1'

# get url of bitbucket
if File.exist? '/etc/bitbucket_url.txt'
  begin
    file = File.open('/etc/bitbucket_url.txt', 'rb')
    bitbucket_url = file.read
  rescue
    file_exists = false
  end
end

if file_exists
  begin
    info = OpenURI.open_uri(bitbucket_url, &:read)
  rescue
    url_read = false
  end
end

if url_read
  pinfo = JSON.parse(info)
  pinfo.each do |key, value|
    actual_value = value
    if value.is_a? Array
      actual_value = value.join(',')
    end
    if key.chomp == 'version'
      version = "bitbucket_#{key.chomp}=#{actual_value.chomp}"
    elsif key.chomp == 'buildNumber'
      build_number = "bitbucket_#{key.chomp}=#{actual_value.chomp}"
    elsif key.chomp == 'displayName'
      display_name = "bitbucket_#{key.chomp}=#{actual_value.chomp}"
    elsif key.chomp == 'buildDate'
      build_date = "bitbucket_#{key.chomp}=#{actual_value.chomp}"
    end
  end
end

Facter.add(:bitbucket_version) do
  setcode do
    version
  end
end
Facter.add(:bitbucket_displayName) do
  setcode do
    display_name
  end
end
Facter.add(:bitbucket_buildNumber) do
  setcode do
    build_number
  end
end
Facter.add(:bitbucket_buildDate) do
  setcode do
    build_date
  end
end
