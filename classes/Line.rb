require "colorize"

class Line
    attr_reader :stations, :distances, :direction, :color
    attr_accessor :line_name

    @@all_lines = []

    def initialize (line_name, stations, distances, direction, color)
        @line_name = line_name              #string
        @stations = stations                #array of station objects
        @distances = distances                #array of distances between each station
        @direction = direction              #direction NS or EW
        @color = color                      #string
        @@all_lines.push(self)
    end

    def self.all_lines
        @@all_lines
    end

    def print_line
        #prints the Line object by representing it with 'o' as stations and '-' as spaces between stations                      
        ind = 0
        @stations.each{|stat|
            if(stat.isInterchange == false)
                print "O"           #print o if station
            elsif(stat.isInterchange == true)
                print "\u25a0".encode('utf-8')
            end

            if(ind < (@distances.length))
                @distances[ind].times do         #check if NaN
                    print "\u257c".encode('utf-8').colorize(@color.to_sym)       #print - if space
                end
            end
            ind += 1
        }
        print "    <- #{@line_name} -- #{@direction}\n"
        @stations.each{|stat|
        print " #{stat.station_name} "
        }
        print "\n"
    end

    def stations_names
        stat_arr = []
        @stations.each{|item|
            stat_arr.push(item.station_name)
        }
        return stat_arr
    end
end