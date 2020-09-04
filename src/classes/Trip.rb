require_relative "./Station.rb"
require_relative "./Line.rb"
require_relative "./Train.rb"

class Trip

    @@all_trip = []

    def initialize (origin, destination,time)
        @origin_num = origin
        @destination_num = destination
        @origin = Station.all_stations[origin]
        @destination = Station.all_stations[destination]
        @trip_path = []
        @time = time
        @pa = {}
        @trip_start = @time
        @trip_finish = 0
        @visited = {}
        @@all_trip.push(self)
        Station.all_interchange.each{ |k,v|
            @visited[k] = false
        }
    end

    def self.all_trip
        @@all_trip
    end

    def visit_check()
        @visited.each{ |inter,v|
            if v == false
                return false
            end
        }
        return true
    end

    def cal_trip()
        origin_line = []
        destination_line = []
        inter_list = []
        found_path = false
        attempts = 0;
        
        print "\n"
        Line.all_lines.each{|k,line|    
            line.stations.each{|station|                                                    #look at all of the stations or each line
                if (station.station_name == @origin)                                        #when found a match for the origin
                    print "Origin - #{station.station_name} - #{line.line_name} Line (#{@origin_num})\n"    #print info
                    origin_line.push([line.line_name])                                      #list all the lines connected to this station
                elsif(station.station_name == @destination)                                 #when found a match for the destination
                    print "Destination - #{station.station_name} - #{line.line_name} Line (#{@destination_num})\n"  #print infor
                    destination_line.push([line.line_name])                                 #list all the lines connected to this station
                end
            }
        }
        print "\n"

        # print "O - #{origin_line}\n"
        # print "D - #{destination_line}\n"  

        path = origin_line;
        inter = []

        #---------------------------------------------------------------------------------------------------------




        while !found_path                                                               #loop until path is found
            # print "visit all #{visit_check()}\n"
            if(visit_check())                              #if number of attempts exceeds the number of interchanges
                print "Can not reach station\n"                                         #path not found 
                break                                                                   #break and final_path will remain []
            end

            if(origin_line & destination_line != [])                                    #if on the same line
                found_path = true                                                       #path is found
                @trip_path = [{lines: ((origin_line & destination_line).flatten), stations: [@origin, @destination]}]
                # print "!!#{@trip_path} \n"
                # @trip_path[:stations] = [@origin, @destination]                                         #update trip
                # @trip_path[:lines] = (origin_line & destination_line).flatten;                 #path is the origin line

            elsif(origin_line & destination_line == [])                                 #if on different lines
                path_temp = path                                                        #put path in a temporary varible
                path = []                                                               #clear path
                s_ind = 0                                                               #initilise the station index

                path_temp.each{|item|                                                   #for each path in the temporary varible
                    link = false                                                        #initilise link varible
                    # print "line #{item[item.length-1]}\n"
                    inter_save = []

                    Line.all_lines[item[item.length-1]].interchanges.each{|k,v|         #look at interchanges on line
                        # print "interchange - line - #{k} -- #{v}\n"
                        # print "test - #{([item[item.length - 1]] & v)} \n\n"

                        if((!([item[item.length - 1]] & v).empty?) && @visited[k] == false)
                            #if the last item of the path has a interchange
                            link = true                                                 #link is discovered

                            path[s_ind] = (item | v)                                    #merge the path and the intesection
                            
                            if(inter[s_ind] == nil)                                     #if no interchange at index
                                inter[s_ind] = []                                       #create an empty array
                            end

                            if inter_save != []
                                inter_save.each{ |inter_item|
                                    inter[s_ind].push(inter_item)
                                }
                                
                            end

                            inter[s_ind].push(k)                                        #push interchange to array
                            inter_save = inter[s_ind][0...-1];
                            @visited[k] = true;

                            # print "Visited #{@visited}\n"
                            # print "Path - #{path} \n"
                            # print "Path_Temp - #{path_temp}\n"
                            # print "Inter - #{inter}\n"
                            # print "inter_save - #{inter_save}\n\n"
                            s_ind += 1                                                  #increment index
                        end
                        
                    }
                    if(!link)                                                           #if can't find a interchange
                        path[s_ind] = []                                                #set path to empty array
                        s_ind += 1                                                      #increment index
                    end
                }

                path.each_index{|item_index|                                            #for each calculated path
                    # print "!!#{path[item_index]} -- #{destination_line}\n"
                    destination_line.each{ |des_item|                                   #look at lines connected to destination
                        if(path[item_index] & (des_item) != [])                             #if path matches a line that is connected to the destination
                            # print "path #{path[item_index]}\n"
                            found_path = true                                               #path is found
                            @trip_path.push({lines: path[item_index], stations:[@origin,inter[item_index],@destination].flatten})
                            # @trip_path[:lines].push(path[item_index])                                #final_path is the path that is found
                            # @trip_path[:stations].push([@origin,inter[item_index],@destination].flatten)        #trip is the origin, all the interchanges in between and the destination
                        end
                    } 
                }
            end
        end

        #------------------------------------------------------------------------------------------------------

        # print "Trips - #{@trip_path}\n"
        # print "--------------------------\n"
        

        #get Line.stations_names
        #get Line.distances

        #example* @final_path = [district, express, victoria]
        #example* @trip = [origin, inter1, inter2, destination]

        @trip_path.each_with_index{ |trip,i|
            # print "trip cal - #{trip}\n"
            cal_times(trip)
            print "\n______Trip #{i+1}______\n"
            trip[:message].each{ |m|
                print m
            }
        }

    end

    def cal_times(trip_path)

        trip_ind = 0
        final_trip = []
        # print "--#{trip_path}-- \n"
        

        for line in trip_path[:lines]
            # print "line - #{line} \n"

            line_ind1 = (Line.all_lines[line].stations_names.index(trip_path[:stations][trip_ind]))        #starting point on line - example* origin
            line_ind2 = (Line.all_lines[line].stations_names.index(trip_path[:stations][trip_ind+1]))      #ending point on line - example* inter1
            # print "l1 #{line_ind1} l2 #{line_ind2}\n"

            last_station = (line_ind2 == (Line.all_lines[line].stations.length - 1))        #check if it is the last station on line
            first_station = (line_ind2 == 0)                                                #check if it is the first station on line
            
            

            
            # print "all_lines #{Line.all_lines[line].direction}\n"

            if(line_ind1 > line_ind2)                           #if starting point is greater than the ending point (going N or E)
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{trip_path[:stations][trip_ind]} N")
                    final_trip.push("#{trip_path[:stations][trip_ind + 1]} #{(first_station)? 'S' : 'N'}")         #if first station, change to S (train turns around)
                when "EW"
                    final_trip.push("#{trip_path[:stations][trip_ind]} E")
                    final_trip.push("#{trip_path[:stations][trip_ind + 1]} #{(first_station)? 'W' : 'E'}")         #if first station, change to S (train turns around)
                end
            elsif(line_ind1 < line_ind2)                        #if ending point is greater than the starting point (going S or W)
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{trip_path[:stations][trip_ind]} S")
                    final_trip.push("#{trip_path[:stations][trip_ind + 1]} #{(last_station)? 'N' : 'S'}")          #if first station, change to S (train turns around)
                when "EW"
                    final_trip.push("#{trip_path[:stations][trip_ind]} W")
                    final_trip.push("#{trip_path[:stations][trip_ind + 1]} #{(last_station)? 'E' : 'W'}")          #if first station, change to S (train turns around)
                end
            end

            # print "Final Trip #{final_trip}\n"
            trip_ind += 1                       #increment the trip index - example* will calculate trip between (origin -> inter1) (inter1 -> inter2) (inter2 -> destination)

        end
        #example* final trip will be [origin N, inter1 N , inter1 E, inter2 W, inter2 S, destination S] (inter2 is first station)
        

        trip_list = []
        trip_ind = 0

        while (trip_ind < final_trip.length - 1)
            query_temp = []
            
            Train.all_trains.each{|train|                                                               #for each train
                query = train.trip_query(final_trip[trip_ind], final_trip[trip_ind+1], @trip_start)       #ask for starting and ending point on line at @time - example [origin N, inter1 N]
                if(query)
                    query_temp.push(query)                                                          #push result to array (multiple trains)
                end
            }

            # print "qt1 - #{query_temp}\n"
            query_temp.sort!                        #sort by earliest train
            # print "qt2 - #{query_temp[0]}\n"

            #trip list is an array of instructions
            trip_list.push("Wait for #{query_temp[0][0]}".ljust(15) +" Train leaves #{final_trip[trip_ind]} (#{query_temp[0][3]} Line) at #{query_temp[0][1]}".ljust(50) +" ->   arrives #{final_trip[trip_ind+1]} at  #{query_temp[0][2]}\n")
            # @pa[query_temp[0][1]] = "Now arriving at #{final_trip[trip_ind]}\n"
            # @pa[query_temp[0][2]] = "Now arriving at #{final_trip[trip_ind+1]}\n"


            @time = query_temp[0][2]
            trip_ind += 2                           #increment to next part of trip - example [inter1 E, inter2 W]
        end
        
        @trip_finish = @time
        trip_path[:message] = trip_list
        trip_path[:finish] = @trip_finish
        # print "trip finish -- #{trip_path[:finish]}\n"

    end

    # def travel
    #     # print "entering travel\n"
    #     (@trip_finish - @trip_start).times{|time|
    #         print "-#{time + 1 + @trip_start}"

    #         if(@pa[time + 1 + @trip_start] != nil)
    #             print "\n PA - #{@pa[time + 1 + @trip_start]}"
    #             sleep(0.5)
    #             print " Mind the gap\n\n"
    #             sleep(1)
    #         end
    #         sleep(1)
    #     }
    # end
    
end