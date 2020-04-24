require_relative "./Station.rb"
require_relative "./Line.rb"

class Trip
    def initialize (origin, destination)
        @origin_num = origin
        @destination_num = destination
        @origin = Station.all_stations[origin]
        @destination = Station.all_stations[destination]
        @trip = []
        @final_path = []
    end

    def cal_trip()
        origin_line = []
        destination_line = []
        inter_list = []
        found_path = false
    
        Line.all_lines.each{|line|
            line.stations.each{|station|
                if (station.station_name == @origin)
                    print "Origin - #{station.station_name} - #{line.line_name} Line - interchange #{station.isInterchange} (#{@origin_num})\n"
                    origin_line.push(line.line_name)
                elsif(station.station_name == @destination)
                    print "Destination - #{station.station_name} - #{line.line_name} Line - interchange #{station.isInterchange} (#{@destination_num})\n"
                    destination_line.push(line.line_name)
                end
            }
        }

        print "O - #{origin_line}\n"
        print "D - #{destination_line}\n"  

        path = [origin_line];
        inter = []

        while !found_path
            if(origin_line & destination_line != [])      
                #if on the same line
                found_path = true
                @trip = [@origin, @destination]
                @final_path = origin_line

            elsif(origin_line & destination_line == [])
                #if on different lines
                path_temp = path
                path = []
                
                p_ind = 0
                s_ind = 0

                path_temp.each{|item|
                    Station.all_interchange.each{|k,v|
                        if((!([item[item.length - 1]] & v).empty?) && ((item | v).sort != item.sort))
                            path[s_ind] = (item | v)
                            
                            if(inter[s_ind] == nil)
                                inter[s_ind] = []
                            end

                            inter[s_ind].push(k)

                            print "P - #{path} PT - #{path_temp}\n"
                            print "I - #{inter}\n"
                            print "P_i #{p_ind}\n"
                            s_ind += 1
                        end
                        
                    }
                    p_ind += 1
                }

                path.each_index{|item_index|
                    # print "!!#{path[item_index]}\n"
                    if(path[item_index] & (destination_line) != [])
                        found_path = true
                        @final_path = (path[item_index])
                        @trip = [@origin,inter[item_index],@destination].flatten
                    end
                }
                # print "pause \n"
                # gets
            end
        end

        print "Trip - #{@trip}\n"
        print "Path - #{@final_path}\n"
        print "--------------------------\n"

        #get Line.stations_names
        #get Line.distances

        #calculate N.S,E,W from station names (dir)

        #look for "trip[1] dir" - depart
        #look for "trip[2] dir" - arrive

        #look for "trip[2] dir" - depart
        #look for "trip[3] dir" - arrive
        
        #look for "trip[3] dir" - depart
        #look for "trip[4] dir" - arrive

    end
    
end