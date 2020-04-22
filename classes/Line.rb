require "colorize"

class Line
    attr_reader :stations, :distance, :direction, :color
    attr_accessor :line_name
    # @@train_arr = []

    def initialize (line_name, stations, distance, direction, color)
        @line_name = line_name              #string
        @stations = stations                #array of station objects
        @distance = distance                #array of distances between each station
        @direction = direction              #direction NS or EW
        @color = color                      #string
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

            if(ind < (@distance.length))
                @distance[ind].times do         #check if NaN
                    print "\u257c".encode('utf-8').colorize(@color.to_sym)       #print - if space
                end
            end
            ind += 1
        }
        print "    <- #{@line_name} -- #{@direction}\n"
        @stations.each{|stat|
        print "#{stat.station_name} - "
        }
        print "\n"
    end
end