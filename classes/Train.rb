#   Train obj
#       - starting point
#       - direction -> (north-bound, west-bound)
#       - cal_time()    -> calculate time train will arrive at each station
require_relative "./Line.rb"

class Train < Line
    attr_reader :start_point, :train_direction

    def initialize (start_point, train_direction)
        super line_name, stations, distance, direction, color
        @start_point = start_point
        @train_direction = train_direction
        print "Train -- > #{@start_point} -- #{@train_direction} -- #{@line_name}\n"
    end

    def cal_time
        #Station - time
        #start at 6:00
        time = 600
        timetable = [[600,@start_point]]

        while time < 700
        #iterate until 18:00
        #look at line
            #@stations search for @start_point index(ind_x)
        print "train at station - #{@stations.index(@start_point)} \n"
        #for each station
        #time  = Line.distance(ind_x) / 0.2
        time += distance[@stations.index(@start_point)]
        print "time - #{}"
        #if last station - turn around
        end
    end
end