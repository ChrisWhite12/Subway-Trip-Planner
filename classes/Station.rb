require_relative "./Line.rb"

class Station < Line
    attr_reader :station_name
    attr_accessor :isInterchange, :zone 

    def initialize (station_name,zone = 1, isInterchange = false)
        super line_name, stations, distance, direction
        @station_name = station_name
        @zone = zone
        @isInterchange = isInterchange
    end

end