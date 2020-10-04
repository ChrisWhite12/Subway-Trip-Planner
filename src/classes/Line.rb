require "colorize"

class Line
    attr_reader :stations, :distances, :direction, :color
    attr_accessor :line_name, :start_xy

    @@all_lines = {}                        #hash of all lines, updates when new line created

    def initialize (line_name, stations, distances, direction, color, start_xy = [0,0])
        @line_name = line_name              #string
        @stations = stations                #array of station objects
        @distances = distances              #array of distances between each station
        @direction = direction              #direction NS or EW
        @color = color                      #string
        @interchanges = {}
        @start_xy = start_xy
        @@all_lines[line_name] = (self)     #place object into all_lines hash with the line_name as key
    end

    def self.all_lines
        @@all_lines
    end

    def interchanges
        @interchanges
    end

    def print_line
        #prints the Line object by representing it with 'o' as stations and '-' as spaces between stations                      
        ind = 0
        print "    "
        @stations.each{|stat|                               #go through each station on the line
            if(stat.isInterchange == false)
                print "\u25ef".colorize(color: @color.to_sym)                                   #print o if station
            elsif(stat.isInterchange == true)
                print "\u25a0".encode('utf-8')              #print square if interchange
            end

            if(ind < (@distances.length))                   #do for each 
                @distances[ind].times do         
                    print "\u257e".encode('utf-8').colorize(color: @color.to_sym)       #print - if space
                end
            end
            ind += 1
        }
        print "    <- #{@line_name} Line -- #{@direction}\n"
        @stations.each_with_index{|stat,ind|
            print ("#{stat.station_name}(#{stat.num})".ljust(30))
            if((ind + 1) % 4 == 0)
                print "\n"
            end
        }
        print "\n\n"
    end

    def stations_names
        stat_arr = []
        @stations.each{|item|
            stat_arr.push(item.station_name)
        }
        return stat_arr
    end
end