class Station
    attr_reader :station_name, :line_name
    attr_accessor :isInterchange, :zone

    #make all_stations a class varible
    @@all_stations = {}
    @@station_num = 100
    #remove stations that become intersections

    def initialize (station_name, line_name, zone = 1, isInterchange = false)
        @station_name = station_name                #string
        @line_name = line_name
        @zone = zone                                #Interger
        @isInterchange = isInterchange              #boolen
        @@all_stations[@@station_num] = station_name
        @@station_num += 1
    end

    def self.all_stations
        @@all_stations
    end
end