require_relative "./Line.rb"

class Train
    attr_reader :start_point, :train_direction, :timetable, :line_name

    @@all_trains = []               #array of train objects

    def initialize (start_num, train_direction, line, speed = 1)
        @start_num = start_num                                      #station start number           integer
        @start_point = line.stations[@start_num].station_name       #start station name             string
        @train_direction = train_direction                          #direction                      string
        @station_arr = line.stations_names                          #list of line names             array of string
        @distances = line.distances                                 #list of distances of line      array of integer
        @station_index = @start_num                                 #current station index          integer
        @line_name = line.line_name                                 #line name                      string
        @timetable = {}                                             #timetable for this train       hash of array of interger
        @speed = speed
        
        @@all_trains.push(self)                                     #array of train objects         array of obj

        #if first station - change direction
        if(@station_index == 0)
            case line.direction                 #check line direction
            when 'NS'
                @train_direction = 'S'
            when 'EW'
                @train_direction = 'W'
            end
        end
        
        #if last station - change direction
        if(@station_index == (@station_arr.length - 1))
            case line.direction                 #check line direction
            when 'NS'
                @train_direction = 'N'
            when 'EW'
                @train_direction = 'E'
            end
        end
        
        # print "Train created - #{@start_point} - #{@train_direction}\n"
    end

    def self.all_trains
        @@all_trains
    end

    def cal_time(time_max)               #calculated the timetable for this train
        time = 1                #starting time
        @timetable = {"#{@start_point} #{@train_direction}" => [1]}     #add time for starting station

        while time < time_max                                               #iterate over time_max
            if(@train_direction == "E")                             #if going East
                # print "s_i - #{@station_index} |"
                # print "dist - #{@distances[@station_index]} |"

                time += @distances[(@station_index - 1)] / @speed           #time = distance/speed 

                if(@station_index > 1)                              #if not first station
                    @station_index = (@station_index - 1)           #new index is index - 1
                elsif(@station_index <= 1)                          #if first station change direction
                    @train_direction = "W"
                    @station_index = 0                              #new index is 0
                end

            elsif(@train_direction == "W")                          #if going West
                # print "s_i - #{@station_index} |"
                # print "dist - #{@distances[@station_index]} |"

                time += @distances[@station_index] / @speed                  #time = distance/speed 

                if(@station_index < (@station_arr.length - 2))      #if not last station
                    @station_index = @station_index + 1             #new index is index + 1
                elsif @station_index >= (@station_arr.length - 2)   #if last index
                    @train_direction = "E"                          #change direction 
                    @station_index = (@station_arr.length - 1)      #new index is last index
                end

            elsif(@train_direction == "N")                          #if going North

                    time += @distances[(@station_index - 1)] / @speed        #time = distance/speed  
    
                    if(@station_index > 1)                          #if not first station
                        @station_index = (@station_index - 1)       #new index is index - 1
                    elsif(@station_index <= 1)                      #if first station
                        @train_direction = "S"                      #change direction
                        @station_index = 0                          #index = 0
                    end
    
            elsif(@train_direction == "S")                         #if going South

                    time += @distances[@station_index] / @speed         #time = distance/speed 
    
                    if(@station_index < (@station_arr.length - 2))      #if not last station
                        @station_index = @station_index + 1             #new index is index + 1
                    elsif @station_index >= (@station_arr.length - 2)   #if last station
                        @train_direction = "N"                          #change direction
                        @station_index = (@station_arr.length - 1)      #new index is last index
                    end
            end
            
            if(@timetable.has_key?("#{@station_arr[@station_index]} #{@train_direction}"))      #check if key already exists
                @timetable["#{@station_arr[@station_index]} #{@train_direction}"].push(time)    #push time to array
            else
                @timetable["#{@station_arr[@station_index]} #{@train_direction}"] = [time]      #create array with time
            end


        end
    end

    def trip_query(origin, destination, time, ad_time = 'D')      
        if(timetable[origin] && timetable[destination])                                 #if there is a timetable for origin and destination
            if(ad_time == "D")                                #time is departure time

                depart_time = timetable[origin].select{|train_time| train_time > time}      #look at time at origin station, return times greater than asked time 
                
                if(depart_time == [])                                                       #if depart_time doesn't exist raise error
                    raise TimeError
                end
                
                arrive_time = timetable[destination].select{|train_time| train_time > depart_time.min} #look at time at origin station, return times greater than asked time

                if(arrive_time == [])                                                       #if arrive_time doesn't exist raise error
                    raise TimeError
                end

                # print "depart_ time #{depart_time} -- "
                # print "arrival time #{arrive_time}\n"

                wait = depart_time.min - time                                   #calculate wait time
                depart_out = depart_time.min
                arrive_out = arrive_time.min

            elsif(ad_time == "A")                             #time is arrival time --- not implemented
                depart_time = timetable[origin].select{|train_time| train_time < time}      #look at time at origin station, return times greater than asked time 

                if(depart_time == [])                                                       #if depart_time doesn't exist raise error
                    raise TimeError
                end
                
                arrive_time = timetable[destination].select{|train_time| train_time < depart_time.max} #look at time at origin station, return times greater than asked time

                if(arrive_time == [])                                                       #if arrive_time doesn't exist raise error
                    raise TimeError
                end
                
                depart_out = depart_time.max
                arrive_out = arrive_time.max
                wait = 0;
            end
            return [wait, depart_out, arrive_out, @line_name]     #return times
        end
    end
end