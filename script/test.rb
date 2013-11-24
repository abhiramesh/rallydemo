require 'mechanize'
require "json"

a = Mechanize.new

array = []
hash = Hash.new
response = a.get("http://maps.googleapis.com/maps/api/geocode/json?address=upper+quad+gate+Philadelphia&sensor=false")

lat = JSON.parse(response.content)["results"][0]["geometry"]["bounds"]["northeast"]["lat"]
lng = JSON.parse(response.content)["results"][0]["geometry"]["bounds"]["northeast"]["lng"]

hash.merge!("lat" => lat.to_s)
hash.merge!("lng" => lng.to_s)

array << hash

array.each do |a|
	puts a["lat"]
end

current_user.friends.find_each do |f|
myinvites = f.eventinvites
@eventinvites.concat(myinvites)
end