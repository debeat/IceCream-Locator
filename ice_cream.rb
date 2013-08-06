require 'addressable/uri'
require 'json'
require 'nokogiri'
require 'rest-client'
require 'yaml'

class IceCream

  def initialize
  end

  def run
    origin = get_origin

    places = find_places(origin)

    destination = choose_destination(places)

    directions = find_directions(origin, destination)

    output_directions(directions)
  end

  def choose_destination(places)
    output_destination_choices(places)

    print "Select a location (number): "

    p_num = gets.chomp.to_i
    destination = places["results"][p_num - 1]["formatted_address"]
  end

  def find_directions(origin, destination)
    directions_params = {
      :origin => origin,
      :destination => destination,
      :mode => 'walking',
      :sensor => false
    }

    directions_endpoint = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/directions/json",
        :query_values => directions_params
        ).to_s

    directions_response = RestClient.get(directions_endpoint)
    directions = JSON.parse(directions_response)
  end

  def find_places(origin)
    places_params = {
      :query => "ice cream in #{origin}",
      :key => "Your Key Here",
      :sensor => false
    }

    places_endpoint = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/place/textsearch/json",
        :query_values => places_params
        ).to_s


    places_response = RestClient.get(places_endpoint)
    places = JSON.parse(places_response)
  end

  def get_origin
    print "Enter street address (San Francisco only!): "
    origin = gets.chomp + ", San Francisco, CA"
  end

  def output_destination_choices(places)
    places["results"].each_with_index do |place, i|
      puts "#{i + 1}. #{place["name"]}: #{place["formatted_address"].split(",").first}"
    end
  end

  def output_directions(directions)
    overall_distance = directions["routes"][0]["legs"][0]["distance"]["text"]

    puts "Overall distance: #{overall_distance}"

    # steps to detination
    directions["routes"][0]["legs"][0]["steps"].each_with_index do |step, i|
      puts "#{i + 1}. #{Nokogiri::HTML(step["html_instructions"]).text} - #{step["distance"]["text"]}"
    end
  end
end

ice = IceCream.new
ice.run

