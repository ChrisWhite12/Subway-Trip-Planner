class Station
    attr_reader :station_name, :line_name, :num
    attr_accessor :isInterchange

    @@all_stations = {}
    @@station_nums = 100
    @@all_interchange = {}

    def initialize (station_name, isInterchange = false)
        @station_name = station_name                #string
        @isInterchange = isInterchange              #boolen
        @num = @@station_nums                       #integer
        @@all_stations[@@station_nums] = station_name   #hash of all of the station names relating to a number
        @@station_nums += 1                         #increment the station number with each one created
    end

    def self.all_stations
        @@all_stations
    end

    def self.all_interchange
        @@all_interchange
    end

    def make_interchange(line1,line2)                           
        @isInterchange = true                                   #make a interchange
        @@all_interchange[@station_name] = [line1,line2]        #add to intersection has with the station name and the lines they intersect
        Line.all_lines[line1].interchanges[@station_name] = [line1,line2]
        Line.all_lines[line2].interchanges[@station_name] = [line1,line2]
    end
end