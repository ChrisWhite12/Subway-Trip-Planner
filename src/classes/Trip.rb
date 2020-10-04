require_relative "./Station.rb"
require_relative "./Line.rb"
require_relative "./Train.rb"
require "colorize"

class Trip

    @@all_trip = []

    def initialize (origin, destination,time, arrive_depart = 'D')
        @origin_num = origin
        @destination_num = destination
        @origin = (arrive_depart == 'D') ? Station.all_stations[origin] : Station.all_stations[destination]
        @destination = (arrive_depart == 'D') ? Station.all_stations[destination] : Station.all_stations[origin]
        @arrive_depart = arrive_depart
        @trip_path = {}
        @time = time
        @travel_info = []
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

    def update_node(num,node,past_node,line,time_q)
        if((@nodes[node][:weight] == nil || @nodes[node][:weight] > num) && @arrive_depart == 'D')
            @nodes[node][:weight] = num
            @nodes[node][:line] = line
            @nodes[node][:past_node] = past_node
            @nodes[node][:time_q] = time_q 
        elsif((@nodes[node][:weight] == nil || @nodes[node][:weight] < num) && @arrive_depart == 'A')
            @nodes[node][:weight] = num
            @nodes[node][:line] = line
            @nodes[node][:past_node] = past_node
            @nodes[node][:time_q] = time_q 
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

        @nodes[@origin] = {weight: @time, past_node: @origin, visited: false}
        @nodes[@destination] = {weight: nil, past_node: '', visited: false}

        
        if(origin_line & destination_line != [])                                    #if on the same line
            found_path = true                                                       #path is found
            # print "#{(origin_line & destination_line).flatten} #{[@origin,@destination].flatten} #{@time}\n"
            time_q = cal_times({lines: (origin_line & destination_line).flatten[0], stations:[@origin,@destination].flatten, time: @time})
            @trip_path = {lines: ((origin_line & destination_line).flatten), stations: [@origin, @destination], time_info: [time_q]}
            
            if(@arrive_depart == 'D')                #depart by
                @trip_path[:time_info].each{|info|
                    @travel_info.push("Wait for #{info[0]}, board train at #{info[1]} (station #{info[4]}) on the #{info[3]} line\n")
                    @travel_info.push("Disembark at station #{info[5]} at #{info[2]}\n\n")
                }
            elsif(@arrive_depart == 'A')             #arrive by
                @trip_path[:time_info].each{|info|
                    @travel_info.push("Board train at #{info[1]} (station #{info[5]}) on the #{info[3]} line\n")
                    @travel_info.push("Disembark at station #{info[4]} at #{info[2]}, wait for #{info[0]}\n\n")
                }
            end
        
        else
            [origin_line].flatten.each{ |o_line|
                # print "oline #{o_line}\n"
                Line.all_lines[o_line].interchanges.each{|k,v|
                    if(k != @origin)
                        time_q = cal_times({lines: o_line, stations:[@origin,k].flatten, time: @time})
                        time_w = (@arrive_depart == 'D') ? time_q[2] : time_q[1]
                        # print "Inter - #{k} w - #{time_w}\n"
                        update_node(time_w,k,@origin,o_line,time_q)
                        # print "!! #{k} - #{@nodes[k]}\n"
                    end
                }
                @nodes[@origin][:visited] = true
            }

            while !found_path
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
                                time_q = cal_times({lines: line, stations: [inter_process, k], time: @nodes[inter_process][:weight]})
                                time_w = (@arrive_depart == 'D') ? time_q[2] : time_q[1]
                                # print "trip processed - #{line}, #{[inter_process, k]}, #{@nodes[inter_process][:weight]}\n"
                                update_node(time_w,k,inter_process,line,time_q)
                                # @nodes.each{|node|
                                #     p node
                                # }
                                # byebug
                                # print "\n"
                            end
                        }
                        if([destination_line].flatten.include?(line))
                            # print "FOUND DESTINATION #{inter_process}\n" 
                            time_q = cal_times({lines: line, stations: [inter_process, @destination], time: @nodes[inter_process][:weight]})
                            # time_w = (@arrive_depart == 'D') ? time_q[2] : time_q[1]
                            time_w = (@arrive_depart == 'D') ? time_q[2] : time_q[1]
                            # print "trip processed - #{line}, #{[inter_process, @destination]}, #{@nodes[inter_process][:weight]}\n"
                            @nodes[@destination] = {weight: time_w, past_node: inter_process, visited: true, line: line, time_q: time_q}    
                            found_path = true
                            @nodes.each{|node|
                                p node
                            }

                            @trip_path = {lines: [], stations: [], time_info: []}
                            node_search = @destination

                            while (node_search != @origin)
                                
                                @trip_path[:lines].push(@nodes[node_search][:line])
                                @trip_path[:stations].push(node_search)
                                @trip_path[:time_info].push(@nodes[node_search][:time_q])
                                node_search = @nodes[node_search][:past_node]
                                # p node_search
                            end
                            @trip_path[:stations].push(@origin)

                            if(@arrive_depart == 'D')                #depart by
                                @trip_path[:stations].reverse!
                                @trip_path[:lines].reverse!
                                @trip_path[:time_info].reverse!
                                # print "arrival time #{time_w}\n"
                                @trip_path[:time_info].each{|info|
                                    @travel_info.push("Wait for #{info[0]}, board train at #{info[1]} (station #{info[4]}) on the #{info[3]} line\n")
                                    @travel_info.push("Disembark at station #{info[5]} at #{info[2]}\n\n")
                                }
                            elsif(@arrive_depart == 'A')             #arrive by
                                # print "depature time #{time_w}\n"
                                @trip_path[:time_info].each{|info|
                                    @travel_info.push("Board train at #{info[1]} (station #{info[5]}) on the #{info[3]} line\n")
                                    @travel_info.push("Disembark at station #{info[4]} at #{info[2]}, wait for #{info[0]}\n\n")
                                }
                            end
                            
                            
                        end
                    }
                    @nodes[inter_process][:visited] = true
                end
            end
        end

        

        print "trip_path #{@trip_path}\n\n".colorize(color: :green)
        @travel_info.each{|info|
            print info.colorize(color: :green)
        }


    end

    def cal_times(trip_path)
        final_trip = []

        # print "--#{trip_path}-- \n"
        line = trip_path[:lines]
        # print "line - #{line} \n"

        line_ind1 = (Line.all_lines[line].stations_names.index(trip_path[:stations][0]))        #starting point on line - example* origin
        line_ind2 = (Line.all_lines[line].stations_names.index(trip_path[:stations][1]))      #ending point on line - example* inter1
        # print "l1 #{line_ind1} l2 #{line_ind2}\n"
        
        last_station1 = (line_ind1 == (Line.all_lines[line].stations.length - 1))        #check if it is the last station on line
        first_station1 = (line_ind1 == 0)                                                #check if it is the first station on line
        last_station2 = (line_ind2 == (Line.all_lines[line].stations.length - 1))        #check if it is the last station on line
        first_station2 = (line_ind2 == 0)                                                #check if it is the first station on line
        
        first_name = trip_path[:stations][0]
        last_name = trip_path[:stations][1]
        
        # print "all_lines #{Line.all_lines[line].direction}\n"

        if(line_ind1 > line_ind2)                           #if starting point is greater than the ending point (going N or E)
            if(@arrive_depart == 'D')
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{first_name} N")
                    final_trip.push("#{last_name} #{(first_station2)? 'S' : 'N'}")         #if first station, change to S (train turns around)
                when "EW"
                    final_trip.push("#{first_name} W")
                    final_trip.push("#{last_name} #{(first_station2)? 'E' : 'W'}")         #if first station, change to E (train turns around)
                end
            elsif(@arrive_depart == 'A')
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{first_name} #{(last_station1)? 'N' : 'S'}")
                    final_trip.push("#{last_name} S")         #if first station, change to S (train turns around)
                when "EW"
                    final_trip.push("#{first_name} #{(last_station1)? 'W' : 'E'}")
                    final_trip.push("#{last_name} E")         #if first station, change to E (train turns around)
                end
            end
        elsif(line_ind1 < line_ind2)                          #if ending point is greater than the starting point (going S or W)
            if(@arrive_depart == 'D')
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{first_name} S")
                    final_trip.push("#{last_name} #{(last_station2)? 'N' : 'S'}")          #if last station, change to N (train turns around)
                when "EW"
                    final_trip.push("#{first_name} E")
                    final_trip.push("#{last_name} #{(last_station2)? 'W' : 'E'}")          #if last station, change to W (train turns around)
                end
            elsif(@arrive_depart == 'A')
                case Line.all_lines[line].direction             #check line direction
                when "NS"
                    final_trip.push("#{first_name} #{(first_station1)? 'S' : 'N'}")
                    final_trip.push("#{last_name} N")         #if first station, change to S (train turns around)
                when "EW"
                    final_trip.push("#{first_name} #{(first_station1)? 'E' : 'W'}")
                    final_trip.push("#{last_name} W")         #if first station, change to E (train turns around)
                end
            end
        end

        #example* final trip will be [origin N, inter1 N , inter1 E, inter2 W, inter2 S, destination S] (inter2 is first station)
        # print "#{final_trip}\n".colorize(color: :magenta)

        trip_list = []

        
        query_temp = []
        
        Train.all_trains.each{|train|                                                               #for each train
            query = train.trip_query(final_trip[0], final_trip[1], trip_path[:time], @arrive_depart)       #ask for starting and ending point on line at @time - example [origin N, inter1 N]
            if(query)
                query_temp.push(query)                                                          #push result to array (multiple trains)
            end
        }
        # query returns [wait, depart_out, arrive_out, @line_name]
        # print "qt1 - #{query_temp}\n"
        query_temp.sort!                        #sort by earliest train
        # print "qt2 - #{query_temp[0]}\n".colorize(color: :red)

        #trip list is an array of instructions
        #return the arrive time
        return query_temp[0]
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