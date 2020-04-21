require_relative "./Line.rb"

class Station < Line
    attr_reader :station_name, :line_name
    attr_accessor :isInterchange, :zone 

    def initialize (station_name,zone = 1, isInterchange = false)
        super line_name, stations, distance, direction, color
        @station_name = station_name                #string
        @zone = zone                                #Interger
        @isInterchange = isInterchange              #boolen
    end

end