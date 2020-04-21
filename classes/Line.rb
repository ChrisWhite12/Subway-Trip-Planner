require "colorize"
class Line

    def initialize(name, stations, distance, direction)
        @name = name
        @stations = stations
        @distance = distance
        @direction = direction
    end

    def print_line
        ind = 0
        @stations.each{|stat|
            print "O"           #print o if station

            if(ind < (@distance.length))
                @distance[ind].times do         #check if NaN
                    print "\u2501".encode('utf-8').colorize(:blue)       #print - if space
                end
            end
            ind += 1
        }
        print "    <- #{@name}\n"
    end
end