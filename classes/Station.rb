require_relative "./Line.rb"

class Station < Line
    attr_reader :station_name
    attr_accessor :isInterchange, :zone, :line_name

    #make all_stations a class varible
    @@all_stations = {}
    @@station_num = 100
    #remove stations that become intersections

    def initialize (station_name,zone = 1, isInterchange = false)
        @station_name = station_name                #string
        @zone = zone                                #Interger
        @isInterchange = isInterchange              #boolen
        @@all_stations[@@station_num] = station_name
        @@station_num += 1
    end

    def self.all_stations
        @@all_stations
    end
end