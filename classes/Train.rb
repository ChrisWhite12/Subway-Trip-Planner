#   Train obj
#       - starting point
#       - direction -> (north-bound, west-bound)
#       - cal_time()    -> calculate time train will arrive at each station
require_relative "./Line.rb"

class Train
    attr_reader :start_point, :train_direction

    def initialize (start_num, train_direction, line)
        @start_num = start_num
        @start_point = line.stations[@start_num].station_name
        @train_direction = train_direction
        @station_arr = line.stations_names
        @distances = line.distances
        @station_index = @start_num
        @speed = 0.5
        print "Train -- > #{@start_point} -- #{@train_direction}\n"
        # print "station_arr - #{@station_arr} -- dist #{@distances}\n"
    end

    def cal_time
        #Station - time
        #start at 6:00
        time = 600
        timetable = {600 => @start_point}

        while time < 700
        #iterate until 8:00
        #look at distances
            if(@train_direction == "E")
                print "s_i - #{@station_index} |"
                print "dist - #{@distances[@station_index]} |"
                print "s_l - #{@station_arr.length - 1}\n"

                time += @distances[(@station_index - 1)]      #typeError
                timetable[time] = @station_arr[(@station_index - 1)]

                if(@station_index > 1)
                    @station_index = (@station_index - 1)
                else
                    @train_direction = "W"
                    @station_index = 0
                end


            elsif(@train_direction == "W")
                print "s_i - #{@station_index} |"
                print "dist - #{@distances[@station_index]} |"
                print "s_l - #{@station_arr.length - 1}\n"

                time += @distances[@station_index]
                timetable[time] = @station_arr[@station_index]

                if(@station_index <= (@station_arr.length - 2))
                    @station_index = @station_index + 1
                elsif @station_index == (@station_arr.length - 1)
                    @train_direction = "E"
                    @station_index = (@station_arr.length - 1)
                end

            # elsif(@train_direction == "N" && @station_index != 0)
            #     time += @distances[@station_index - 1] / @speed
            # elsif(@train_direction == "S" && @station_index != distances.length)
            #     time += @distances[@station_index] / @speed
            # end
            end
            
        end
        return timetable
    end
end