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
        @trip_path = {}
        @time = time
        @pa = {}
        @trip_start = @time
        @trip_finish = 0
        @time_weight = {}
        @nodes = {}
        @@all_trip.push(self)
        Station.all_interchange.each{ |k,v|
            @time_weight[k] = nil
            @nodes[k] = {weight: nil, past_node: '', visited: false}
        }
    end

    def self.all_trip
        @@all_trip
    end

    def update_node(num,node,past_node,line)
        if(@nodes[node][:weight] == nil || @nodes[node][:weight] > num)
            @nodes[node][:weight] = num
            @nodes[node][:line] = line
            @nodes[node][:past_node] = past_node
        end
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
        #   have nodes = {origin => {weight => 0, visited => []}, inter1 => {weight => [...nil], visited => []}, inter2 => {weight => [...nil], visited => []}}
        # start with lowest weight and look at intersections on the same line(s) as node
        #   calculate the weight

            #/////////////////////////////////////////////////////////////////////////////////////////////////
        @nodes[@origin] = {weight: 0, past_node: @origin, visited: false}
        @nodes[@destination] = {weight: nil, past_node: '', visited: false}

        [origin_line].flatten.each{ |o_line|
            Line.all_lines[o_line].interchanges.each{|k,v|
                time_w = cal_times({lines: o_line, stations:[@origin,k].flatten, time: @time})
                # print "Inter - #{k} w - #{time_w}\n"
                update_node(time_w,k,@origin,o_line)
                # print "!! #{k} - #{@nodes[k]}\n"
            }
            @nodes[@origin][:visited] = true
        }

        while !found_path
            if(origin_line & destination_line != [])                                    #if on the same line
                found_path = true                                                       #path is found
                @trip_path = {lines: ((origin_line & destination_line).flatten), stations: [@origin, @destination]}
            else
                #add origin node to the queue
                # inter_process = queue.shift()
                #if not visited and lowest weight
                weight_temp = 9999
                node_result = ''
                @nodes.each{ |node_key, node_val|
                    if(node_val[:weight] != nil && !node_val[:visited] && node_val[:weight] < weight_temp)
                        weight_temp = node_val[:weight]
                        node_result = node_key
                    end
                }
                inter_process = node_result

                if(!@nodes[inter_process][:visited])
                    # print "inter_process -> #{inter_process}\n"
                    Station.all_interchange[inter_process].each{|line|
                        Line.all_lines[line].interchanges.each{|k,v|
                            if(k != inter_process && !@nodes[k][:visited])
                                time_w = cal_times({lines: line, stations: [inter_process, k], time: @nodes[inter_process][:weight]})
                                print "trip processed - #{line}, #{[inter_process, k]}, #{@nodes[inter_process][:weight]}\n"
                                update_node(time_w,k,inter_process,line)
                                # pp @nodes
                            end
                        }
                        if([destination_line].flatten.include?(line))
                            print "FOUND DESTINATION #{inter_process}\n" 
                            time_w = cal_times({lines: line, stations: [inter_process, @destination], time: @nodes[inter_process][:weight]})
                            print "trip processed - #{line}, #{[inter_process, @destination]}, #{@nodes[inter_process][:weight]}\n"
                            @nodes[@destination] = {weight: time_w, past_node: inter_process, visited: true, line: line}    
                            found_path = true
                            pp @nodes

                            @trip_path = {lines: [], stations: []}
                            node_search = @destination

                            while (node_search != @origin)
                                
                                @trip_path[:lines].push(@nodes[node_search][:line])
                                @trip_path[:stations].push(node_search)
                                node_search = @nodes[node_search][:past_node]
                                # p node_search
                            end
                            @trip_path[:stations].push(@origin)

                            @trip_path[:stations].reverse!
                            @trip_path[:lines].reverse!
                        end
                    }
                    @nodes[inter_process][:visited] = true
                end
            end
            print "trip_path #{@trip_path}\n"
        end
        


    end

    def cal_times(trip_path)
        final_trip = []

        # print "--#{trip_path}-- \n"
        line = trip_path[:lines]
        # print "line - #{line} \n"

        line_ind1 = (Line.all_lines[line].stations_names.index(trip_path[:stations][0]))        #starting point on line - example* origin
        line_ind2 = (Line.all_lines[line].stations_names.index(trip_path[:stations][1]))      #ending point on line - example* inter1
        # print "l1 #{line_ind1} l2 #{line_ind2}\n"

        last_station = (line_ind2 == (Line.all_lines[line].stations.length - 1))        #check if it is the last station on line
        first_station = (line_ind2 == 0)                                                #check if it is the first station on line
        first_name = trip_path[:stations][0]
        last_name = trip_path[:stations][1]
        
        # print "all_lines #{Line.all_lines[line].direction}\n"

        if(line_ind1 > line_ind2)                           #if starting point is greater than the ending point (going N or E)
            case Line.all_lines[line].direction             #check line direction
            when "NS"
                final_trip.push("#{first_name} N")
                final_trip.push("#{last_name} #{(first_station)? 'S' : 'N'}")         #if first station, change to S (train turns around)
            when "EW"
                final_trip.push("#{first_name} E")
                final_trip.push("#{last_name} #{(first_station)? 'W' : 'E'}")         #if first station, change to S (train turns around)
            end
        elsif(line_ind1 < line_ind2)                        #if ending point is greater than the starting point (going S or W)
            case Line.all_lines[line].direction             #check line direction
            when "NS"
                final_trip.push("#{first_name} S")
                final_trip.push("#{last_name} #{(last_station)? 'N' : 'S'}")          #if first station, change to S (train turns around)
            when "EW"
                final_trip.push("#{first_name} W")
                final_trip.push("#{last_name} #{(last_station)? 'E' : 'W'}")          #if first station, change to S (train turns around)
            end
        end

        #example* final trip will be [origin N, inter1 N , inter1 E, inter2 W, inter2 S, destination S] (inter2 is first station)
        

        trip_list = []

        
        query_temp = []
        
        Train.all_trains.each{|train|                                                               #for each train
            query = train.trip_query(final_trip[0], final_trip[1], trip_path[:time])       #ask for starting and ending point on line at @time - example [origin N, inter1 N]
            if(query)
                query_temp.push(query)                                                          #push result to array (multiple trains)
            end
        }
        # query returns [wait, depart_out, arrive_out, @line_name]
        # print "qt1 - #{query_temp}\n"
        query_temp.sort!                        #sort by earliest train
        # print "qt2 - #{query_temp[0]}\n"

        #trip list is an array of instructions
        return query_temp[0][2]
    end
end


# elsif(origin_line & destination_line == [])                                 #if on different lines
#     path_temp = path                                                        #put path in a temporary varible
#     path = []                                                               #clear path
#     s_ind = 0                                                               #initilise the station index
    
#     #----------------------------------------------------------------------------
#     path_temp.each{|item|                                                   #for each path in the temporary varible
#         link = false                                                        #initilise link varible
#         inter_save = []

#         Line.all_lines[item[item.length-1]].interchanges.each{|k,v|         #look at interchanges on line
            
#             if((!([item[item.length - 1]] & v).empty?) && @visited[k] == false)
#                 #if the last item of the path has a interchange
#                 link = true                                                 #link is discovered

#                 path[s_ind] = (item | v)                                    #merge the path and the intesection
                

#                 if(inter[s_ind] == nil)                                     #if no interchange at index
#                     inter[s_ind] = []                                       #create an empty array
#                 end

#                 if inter_save != []                                         #if intersections are saved (multiple intersection per line)
#                     inter_save.each{ |inter_item|
#                         inter[s_ind].push(inter_item)                       #push items onto new intersection path
#                     }
                    
#                 end

#                 inter[s_ind].push(k)                                        #push interchange to array
#                 inter_save = inter[s_ind][0...-1];                          #save the interchanges except for last
                
#                 print "Visited #{@visited}\n"
#                 print "Path - #{path} \n"
#                 print "Path_Temp - #{path_temp}\n"
#                 print "Inter - #{inter}\n"
#                 print "inter_save - #{inter_save}\n\n"

#                 # print "arr #{[@origin,inter[s_ind]].flatten}"
                
#                 print "trip processed - #{path[s_ind][0...-1]}, #{[@origin,inter[s_ind]].flatten}\n"
#                 time_w = cal_times({lines: path[s_ind][0...-1], stations:[@origin,inter[s_ind]].flatten})                           
#                 # print "time - #{inter[s_ind][-1]} #{time_w}\n"
#                 print "TIMES #{@time_weight}\n"
#                 s_ind += 1                                                  #increment index
#             end
            
#             gets
#         }
#         # when finished with all intersections of line?
#         @visited[@origin] = true;
        
#         @visited[inter_save] = true;
        
#         if(!link)                                                           #if can't find a interchange
#             path[s_ind] = []                                                #set path to empty array
#             s_ind += 1                                                      #increment index
#         end
#     }






# path.each_index{|item_index|                                            #for each calculated path
# # print "!!#{path[item_index]} -- #{destination_line}\n"
# destination_line.each{ |des_item|                                   #look at lines connected to destination
#     if(path[item_index] & (des_item) != [])                             #if path matches a line that is connected to the destination
#         # print "path #{path[item_index]}\n"
#         found_path = true                                               #path is found
#         @trip_path.push({lines: path[item_index], stations:[@origin,inter[item_index],@destination].flatten})
#     end
# } 
# }


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

#     @trip_path.each_with_index{ |trip,i|
#     # print "trip cal - #{trip}\n"
#     cal_times(trip)
#     print "________________ Trip #{i+1} _________________\n\n"
#     trip[:message].each{ |m|
#         print m
#     }
# }
# print "_____________________________________________\n"