#   Train obj
#       - starting point
#       - direction -> (north-bound, west-bound)
#       - cal_time()    -> calculate time train will arrive at each station
require_relative "./Line.rb"

class Train
    attr_reader :start_point, :train_direction, :timetable

    def initialize (start_num, train_direction, line)
        @start_num = start_num
        @start_point = line.stations[@start_num].station_name
        @train_direction = train_direction
        @station_arr = line.stations_names
        @distances = line.distances
        @station_index = @start_num
        @timetable = {}
        print "Train -- > #{@start_point} -- #{@train_direction}\n"
        # print "station_arr - #{@station_arr} -- dist #{@distances}\n"
    end

    def cal_time
        #Station - time
        #start at 6:00
        time = 1
        @timetable = {"#{@start_point} #{@train_direction}" => [1]}

        while time < 100
        #iterate until 8:00
        #look at distances
            if(@train_direction == "E")
                # print "s_i - #{@station_index} |"
                # print "dist - #{@distances[@station_index]} |"

                time += @distances[(@station_index - 1)]

                if(@station_index > 1)
                    @station_index = (@station_index - 1)
                elsif(@station_index <= 1)
                    @train_direction = "W"
                    @station_index = 0
                end

            elsif(@train_direction == "W")
                # print "s_i - #{@station_index} |"
                # print "dist - #{@distances[@station_index]} |"

                time += @distances[@station_index]

                if(@station_index < (@station_arr.length - 2))
                    @station_index = @station_index + 1
                elsif @station_index >= (@station_arr.length - 2)
                    @train_direction = "E"
                    @station_index = (@station_arr.length - 1)
                end

            elsif(@train_direction == "N")

                    time += @distances[(@station_index - 1)]
    
                    if(@station_index > 1)
                        @station_index = (@station_index - 1)
                    elsif(@station_index <= 1)
                        @train_direction = "S"
                        @station_index = 0
                    end
    
            elsif(@train_direction == "S")

                    time += @distances[@station_index]
    
                    if(@station_index < (@station_arr.length - 2))
                        @station_index = @station_index + 1
                    elsif @station_index >= (@station_arr.length - 2)
                        @train_direction = "N"
                        @station_index = (@station_arr.length - 1)
                    end
            end
            
            if(@timetable.has_key?("#{@station_arr[@station_index]} #{@train_direction}"))
                @timetable["#{@station_arr[@station_index]} #{@train_direction}"].push(time) 
            else
                @timetable["#{@station_arr[@station_index]} #{@train_direction}"] = [time] 
            end
        end
    end
end