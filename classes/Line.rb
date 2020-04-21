require "colorize"
class Line
    attr_reader :line_name, :stations, :distance, :direction
    @@train_arr = []

    def initialize(line_name, stations, distance, direction)
        @line_name = line_name
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
        print "    <- #{@line_name}\n"
        print "#{stations}\n"
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