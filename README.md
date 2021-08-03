Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

# API
## AMADEUS
GET Points of Interest by Square:
[Documentation here](https://documenter.getpostman.com/view/2672636/RWEcPfuJ#aaeb9b5e-c80c-4185-a0ce-f908351d58f8) \
**INPUT** \
Longitude and Latitude \
**ANSWER** \
The answer is an hash containing the array **data** compose of the following hash:
 ```json
{
  :type=>"location",
  :subType=>"POINT_OF_INTEREST",
  :id=>"180972C098",
  :self=>{:href=>"https://test.api.amadeus.com/v1/reference-data/locations/pois/180972C098", :methods=>["GET"]},
  :geoCode=>{:latitude=>41.399952, :longitude=>2.185743},
  :name=>"Teatre Nacional de Catalunya",
  :category=>"SIGHTS",
  :rank=>200,
  :tags=>["sightseeing", "activities", "tourguide", "theater", "attraction", "commercialplace", "musicvenue"]
 }
 ```
 
 ## OPEN TRIP MAP
GET Points of Interest by Square:
[Documentation here](https://documenter.getpostman.com/view/2672636/RWEcPfuJ#aaeb9b5e-c80c-4185-a0ce-f908351d58f8) \
 **INPUT** \
`
require 'rest-client'
require 'geocoder'
require 'pry-byebug'
KEY = /
###############################
lon = 2.17436
lat = 41.40359
url = "https://api.opentripmap.com/0.1/en/places/radius?radius=100&lon=#{lon}&lat=#{lat}&apikey=" + KEY
response = JSON.parse(RestClient.get(url))
id = response['features'].first['properties']['xid']
place_url = "http://api.opentripmap.com/0.1/en/places/xid/#{id}?apikey=" + KEY
response = RestClient.get(url)
response = JSON.parse(RestClient.get(place_url))
p response['image']`


 **ANSWER**
```json
{
"xid"=>"R9194723", "name"=>"Sagrada Família", "address"=>{"city"=>"Barcelona", "road"=>"Carrer de Mallorca", "house"=>"Basílica de la Sagrada Família", "state"=>"CAT", "county"=>"BCN", "suburb"=>"la Sagrada Família", "country"=>"España", "postcode"=>"08088", "country_code"=>"es", "house_number"=>"403", "city_district"=>"Eixample"}, "rate"=>"3h", "osm"=>"relation/9194723", "bbox"=>{"lon_min"=>2.17374, "lon_max"=>2.174996, "lat_min"=>41.403031, "lat_max"=>41.403899}, "wikidata"=>"Q48435", "kinds"=>"religion,churches,interesting_places,catholic_churches", "voyage"=>"https://ro.wikivoyage.org/wiki/Barcelona%2FSagrada%20Familia", "url"=>"http://www.sagradafamilia.cat;http://www.sagradafamilia.org;http://www.sagradafamilia.cat/", "sources"=>{"geometry"=>"osm", "attributes"=>["osm", "wikidata"]}, "otm"=>"https://opentripmap.com/en/card/R9194723", "wikipedia"=>"https://en.wikipedia.org/wiki/Sagrada%20Fam%C3%ADlia", "image"=>"https://commons.wikimedia.org/wiki/File:%CE%A3%CE%B1%CE%B3%CF%81%CE%AC%CE%B4%CE%B1_%CE%A6%CE%B1%CE%BC%CE%AF%CE%BB%CE%B9%CE%B1_2941.jpg", "preview"=>{"source"=>"https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/%CE%A3%CE%B1%CE%B3%CF%81%CE%AC%CE%B4%CE%B1_%CE%A6%CE%B1%CE%BC%CE%AF%CE%BB%CE%B9%CE%B1_2941.jpg/271px-%CE%A3%CE%B1%CE%B3%CF%81%CE%AC%CE%B4%CE%B1_%CE%A6%CE%B1%CE%BC%CE%AF%CE%BB%CE%B9%CE%B1_2941.jpg", "height"=>400, "width"=>271}, "wikipedia_extracts"=>{"title"=>"en:Sagrada Família", "text"=>"The Basílica i Temple Expiatori de la Sagrada Família (Catalan pronunciation: [səˈɣɾaðə fəˈmili.ə]; Spanish: Templo Expiatorio de la Sagrada Familia; English: Basilica and Expiatory Church of the Holy Family) is a large unfinished Roman Catholic church in Barcelona, designed by Catalan architect Antoni Gaudí (1852–1926). Gaudí's work on the building is part of a UNESCO World Heritage Site, and in November 2010 Pope Benedict XVI consecrated and proclaimed it a minor basilica, as distinct from a cathedral, which must be the seat of a bishop.", "html"=>"<p>The <b><i lang=\"ca\" title=\"Catalan language text\">Basílica i Temple Expiatori de la Sagrada Família</i></b> (<small>Catalan pronunciation:&nbsp;</small><span title=\"Representation in the International Phonetic Alphabet (IPA)\">[səˈɣɾaðə fəˈmili.ə]</span>; Spanish: <i lang=\"es\">Templo Expiatorio de la Sagrada Familia</i>; English: <span lang=\"en\">Basilica and Expiatory Church of the Holy Family</span>) is a large unfinished Roman Catholic church in Barcelona, designed by Catalan architect Antoni Gaudí (1852–1926). Gaudí's work on the building is part of a UNESCO World Heritage Site, and in November 2010 Pope Benedict&nbsp;XVI consecrated and proclaimed it a minor basilica, as distinct from a cathedral, which must be the seat of a bishop.</p>"}, "point"=>{"lon"=>2.17441, "lat"=>41.403481}
}
```
Interesting fields:
- name
- address (city/road/house/state/county/suburb/country/postcode/...)
- rate (duration?)
- kinds => for sagrada familia: religion,churches,interesting_places,catholic_churches
- **url** : contains several link to the official website. ==> for sagrada familia: "http://www.sagradafamilia.cat;http://www.sagradafamilia.org;http://www.sagradafamilia.cat/"
- **wikipedia** : the link to wikimedia page
- **image** : image on wikipedia
- **preview** : hash containing "source": an **image link, height and width**
- **wikipedia_extracts**: hash containing: title, **text** and html
