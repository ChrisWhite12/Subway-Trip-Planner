class Station
    attr_reader :station_name, :line_name, :num
    attr_accessor :isInterchange

    #make all_stations a class varible
    @@all_stations = {}
    @@station_nums = 100
    @@all_interchange = {}
    #remove stations that become intersections

    def initialize (station_name, isInterchange = false)
        @station_name = station_name                #string
        @isInterchange = isInterchange              #boolen
        @num = @@station_nums
        @@all_stations[@@station_nums] = station_name
        @@station_nums += 1
    end

    def self.all_stations
        @@all_stations
    end

    def self.all_interchange
        @@all_interchange
    end

    def make_interchange(line1,line2)
        @isInterchange = true
        @@all_interchange[@station_name] = [line1,line2]
    end
end