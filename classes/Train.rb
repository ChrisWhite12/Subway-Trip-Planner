#   Train obj
#       - starting point
#       - direction -> (north-bound, west-bound)
#       - cal_time()    -> calculate time train will arrive at each station
require_relative "./Line.rb"

class Train
    attr_reader :start_point, :train_direction, :timetable, :line_name

    @@all_trains = []

    def initialize (start_num, train_direction, line)
        @start_num = start_num
        @start_point = line.stations[@start_num].station_name
        @train_direction = train_direction
        @station_arr = line.stations_names
        @distances = line.distances
        @station_index = @start_num
        @line_name = line.line_name
        @timetable = {}
        @@all_trains.push(self)

        #if first station - change direction
        if(@station_index == 0)
            case line.direction
            when 'NS'
                @train_direction = 'S'
            when 'EW'
                @train_direction = 'W'
            end
        end
        
        #if last station - change direction
        if(@station_index == (@station_arr.length - 1))
            case line.direction
            when 'NS'
                @train_direction = 'N'
            when 'EW'
                @train_direction = 'E'
            end
        end
        # print "Train - #{@start_point} - #{@train_direction}\n"
    end

    def self.all_trains
        @@all_trains
    end

    def cal_time
        time = 1
        @timetable = {"#{@start_point} #{@train_direction}" => [1]}

        while time < 100
        #iterate for 100 min
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

    def trip_query(origin, destination, time)
        if(timetable[origin] && timetable[destination])
            depart_time = timetable[origin].select{|train_time| train_time > time}
            arrive_time = timetable[destination].select{|train_time| train_time > time}
            wait = depart_time.min - time
            return [wait, depart_time.min, arrive_time.min, @line_name]
        end
    end
end