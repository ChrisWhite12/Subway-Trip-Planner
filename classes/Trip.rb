require_relative "./Station.rb"
require_relative "./Line.rb"
require_relative "./Train.rb"

class Trip
    def initialize (origin, destination,time)
        @origin_num = origin
        @destination_num = destination
        @origin = Station.all_stations[origin]
        @destination = Station.all_stations[destination]
        @trip = []
        @final_path = []
        @time = time
    end

    def cal_trip()
        origin_line = []
        destination_line = []
        inter_list = []
        found_path = false
        attempts = 0;
    
        Line.all_lines.each{|k,line|
            line.stations.each{|station|
                if (station.station_name == @origin)
                    print "Origin - #{station.station_name} - #{line.line_name} Line (#{@origin_num})\n"
                    origin_line.push([line.line_name])
                elsif(station.station_name == @destination)
                    print "Destination - #{station.station_name} - #{line.line_name} Line (#{@destination_num})\n"
                    destination_line.push([line.line_name])
                end
            }
        }

        # print "O - #{origin_line}\n"
        # print "D - #{destination_line}\n"  

        path = origin_line;
        inter = []

        while !found_path
            if(attempts >= Station.all_interchange.length)
                print "Can not reach station\n"
                break
            end


            if(origin_line & destination_line != [])      
                #if on the same line
                found_path = true
                @trip = [@origin, @destination]
                @final_path = origin_line.flatten!

            elsif(origin_line & destination_line == [])
                #if on different lines
                path_temp = path
                path = []
                attempts += 1
                s_ind = 0

                path_temp.each{|item|
                    link = false
                    Station.all_interchange.each{|k,v|

                        if((!([item[item.length - 1]] & v).empty?) && ((item | v).sort != item.sort))
                            link = true

                            path[s_ind] = (item | v)
                            
                            if(inter[s_ind] == nil)
                                inter[s_ind] = []
                            end

                            inter[s_ind].push(k)

                            # print "P - #{path} PT - #{path_temp}\n"
                            # print "I - #{inter}\n"
                            s_ind += 1
                        end
                        
                    }
                    if(!link)
                            path[s_ind] = []
                            s_ind += 1
                    end
                }

                path.each_index{|item_index|
                    # print "!!#{path[item_index]} -- #{destination_line}\n"
                    destination_line.each{ |des_item|
                    if(path[item_index] & (des_item) != [])
                        found_path = true
                        @final_path = (path[item_index])
                        @trip = [@origin,inter[item_index],@destination].flatten
                    end
                    } 
                }
                # print "pause \n"
                # gets
            end
        end

        # print "Trip - #{@trip}\n"
        # print "Path - #{@final_path}\n"
        # print "--------------------------\n"

        #get Line.stations_names
        #get Line.distances
        trip_ind = 0
        final_trip = []

        while (trip_ind <= @trip.length - 2)
            line = @final_path[trip_ind]
            
            line_ind1 = (Line.all_lines[line].stations_names.index(@trip[trip_ind]))
            line_ind2 = (Line.all_lines[line].stations_names.index(@trip[trip_ind+1]))
            
            last_station = (line_ind2 == (Line.all_lines[line].stations.length - 1))
            first_station = (line_ind2 == 0)

            # print "#{last_station}\n"
            # print "#{Line.all_lines[line].stations.length - 1}\n"
            # print "#{line_ind2}\n"

            if(line_ind1 > line_ind2)                           #going N or E
                case Line.all_lines[line].direction
                when "NS"
                    final_trip.push("#{@trip[trip_ind]} N")
                    final_trip.push("#{@trip[trip_ind + 1]} #{(first_station)? 'S' : 'N'}")
                when "EW"
                    final_trip.push("#{@trip[trip_ind]} E")
                    final_trip.push("#{@trip[trip_ind + 1]} #{(first_station)? 'W' : 'E'}")
                end
            elsif(line_ind1 < line_ind2)                        #going S or W
                case Line.all_lines[line].direction
                when "NS"
                    final_trip.push("#{@trip[trip_ind]} S")
                    final_trip.push("#{@trip[trip_ind + 1]} #{(last_station)? 'N' : 'S'}")
                when "EW"
                    final_trip.push("#{@trip[trip_ind]} W")
                    final_trip.push("#{@trip[trip_ind + 1]} #{(last_station)? 'E' : 'W'}")
                end
            end
            trip_ind += 1
        end
        
        # print "FT #{final_trip} \n"

        trip_list = []
        trip_ind = 0

        while (trip_ind < final_trip.length - 1)
            query_temp = []
            
            Train.all_trains.each{|train|
                query = train.trip_query(final_trip[trip_ind], final_trip[trip_ind+1], @time)
                if(query)
                    query_temp.push(query)
                end
            }

            # print "qt1 - #{query_temp}\n"
            query_temp.sort!
            # print "qt2 - #{query_temp[0]}\n"

            trip_list.push("Wait for #{query_temp[0][0]}, Train leaves #{final_trip[trip_ind]} (#{query_temp[0][3]} Line) at #{query_temp[0][1]} -> arrives #{final_trip[trip_ind+1]} at  #{query_temp[0][2]}\n")
            @time =  query_temp[0][2]
            trip_ind += 2
        end
        print "\n"
        puts trip_list
        print "--------------------------------------------\n"
    end
    
end