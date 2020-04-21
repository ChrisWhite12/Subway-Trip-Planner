require "colorize"
class Line
    attr_reader :line_name, :stations, :distance, :direction
    @@train_arr = []

    def initialize(line_name, stations, distance, direction)
        @line_name = line_name              #string
        @stations = stations                #array of station objects
        @distance = distance                #array of distances between each station
        @direction = direction              #direction NS or EW
    end

    def print_line
        ind = 0
        @stations.each{|stat|
            if(stat.isInterchange == false)
                print "O"           #print o if station
            elsif(stat.isInterchange == true)
                print "\u25a0".encode('utf-8')
            end

            if(ind < (@distance.length))
                @distance[ind].times do         #check if NaN
                    print "\u2501".encode('utf-8').colorize(:blue)       #print - if space
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

    def add_train
        train_direction = ''
        if(@direction == "NS")
            train_direction = 'S'
        elsif(@direction == "EW")
            train_direction = 'E'
        end

        @@Train_arr.push(Train.new(@stations[0], train_direction))
    end
end