require 'addressable/uri'
require 'json'
require 'nokogiri'
require 'rest-client'
require 'yaml'

class IceCream
  attr_accessor :origin, :places, :destination, :directions

  def initialize
  end

  def run
    determine_origin
    find_nearby_shops
    display_choices
    select_shop
    find_directions_to_shop
    display_directions
  end

  def determine_origin
    print "Enter street address (San Francisco only!): "
    @origin = gets.chomp + ", San Francisco, CA"
  end

  def display_choices
    @places["results"].each_with_index do |place, i|
      print "#{i + 1}. #{place["name"]}:"
      print " #{place["formatted_address"].split(",").first}"
      puts
    end
  end

  def display_directions
    overall_distance = @directions["routes"][0]["legs"][0]["distance"]["text"]

    puts "Overall distance: #{overall_distance}"

    # steps to detination
    @directions["routes"][0]["legs"][0]["steps"].each_with_index do |step, i|
      print "#{i + 1}. #{Nokogiri::HTML(step["html_instructions"]).text}"
      print " - #{step["distance"]["text"]}"
      puts
    end
  end

  def find_directions_to_shop
    directions_params = {
      :origin => @origin,
      :destination => @destination,
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
    @directions = JSON.parse(directions_response)
  end

  def find_nearby_shops
    places_params = {
      :query => "ice cream in #{@origin}",
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
    @places = JSON.parse(places_response)
  end

  def select_shop
    print "Select a location (number): "

    p_num = gets.chomp.to_i
    @destination = @places["results"][p_num - 1]["formatted_address"]
  end

end


ice = IceCream.new
ice.run

