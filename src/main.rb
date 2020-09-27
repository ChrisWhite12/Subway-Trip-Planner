require "faker"
require "tts"
require "byebug"
require_relative "./classes/Line.rb"
require_relative "./classes/Train.rb"
require_relative "./classes/Station.rb"
require_relative "./classes/Trip.rb"


# print "#{String.color_samples}\n"

def intersect_lines(line1,line2,stat1,stat2)

    # remove stations that become intercharnges
    Station.all_stations.each{ |k,v|
    if (v == line1.stations[stat1].station_name)
        # print "#{k} #{v} - deleted\n"
        Station.all_stations.delete(k)
    end
    } 

    #replace stat1 with stat2
    line1.stations[stat1] = line2.stations[stat2]
    line1.stations[stat1].make_interchange(line1.line_name,line2.line_name)
    line2.stations[stat2].make_interchange(line1.line_name,line2.line_name)  
end

def generate_stations(num)
    station_arr = []
    num.times do
        station_arr.push(Station.new(Faker::Address.city))              #create station objects
    end
    return station_arr                                                  #return array of station objects
end

def map_dist(y,x,val)
    result = []
    for i in (-val)..(val)
        for j in (-val)..(val)
            result.push([i+y,j+x])
            result.delete([y,x])
        end
    end
    # print "#{result}\n"
    return result
end

def low_diff(arr)
    diff = nil
    if(arr.length < 1)
        return 0
    end

    arr.each_index{|ind1|
        arr.each_index{|ind2|
            if(ind1 != ind2)
                diff_temp = (arr[ind1] - arr[ind2]).abs
                # print "#{diff_temp}\n"
                if (diff == nil || diff_temp < diff)
                    diff = diff_temp
                end
            end
        }
    }
    return diff
end

# print "#{low_diff([1,20,24,15])}\n"

# map_dist(3,3,1)
# map_dist(2,10,1)

def generate_lines(x,y,lines)
    #start with a empty 100x100 grid
    map = Array.new(y){Array.new(x,' ')}
    color_array = ["red","white","blue","yellow","magenta","green"]
    names_array = ["District","Northern","Express","Victoria","Picadilly","Central"]
    map_obj = {}
    lines_NS_xpos = [0]
    lines_EW_ypos = [0]

    #for 3..6 lines for NS and EW
    for i in 0...(lines) do
        # print "i - #{i}\n"
        map_obj[names_array[i].to_sym] = {}
        rand_xs = 0
        rand_xf = 0
        rand_xd = 0
        rand_y_var = nil

        rand_ys = 0
        rand_yf = 0
        rand_yd = 0
        rand_x_var = nil

        oddeven = (i % 2)
        y_spacing = [rand_ys-2, rand_ys-1, rand_ys, rand_ys+1, rand_ys+2]
        x_spacing = [rand_xs-2, rand_xs-1, rand_xs, rand_xs+1, rand_xs+2]

        #random number y for EW or x for NS
        case(oddeven)
        when 0      #when EW
            while !(lines_EW_ypos & y_spacing == [])
                rand_ys = (rand 1...y).floor()
                y_spacing = [rand_ys-3,rand_ys-2, rand_ys-1, rand_ys, rand_ys+1, rand_ys+2,rand_ys+3]
                # print "ys #{rand_ys}\n"
                # print "!!#{lines_EW_ypos & y_spacing} -- #{y_spacing}\n"
            end
            rand_yf = rand_ys
            lines_EW_ypos.push(rand_ys)
            #random number for x_start

            while (rand_xd) < (x/2)
                rand_xs = (rand 1...(x/2)).floor()
                #random number for x_finish
                rand_xf = (rand (x/2)...x).floor()
                rand_xd = rand_xf - rand_xs
            end

        when 1      #when NS
            while !(lines_NS_xpos & x_spacing == [])
                rand_xs = (rand 1...x).floor()
                x_spacing = [rand_xs-3,rand_xs-2, rand_xs-1, rand_xs, rand_xs+1, rand_xs+2,rand_xs+3]
            end
            lines_NS_xpos.push(rand_xs)
            rand_xf = rand_xs
            #random number for x_start

            while (rand_yd) < (y/2)
                rand_ys = (rand 1...(y/2)).floor()
                #random number for x_finish
                rand_yf = (rand (y/2)...y).floor()
                rand_yd = rand_yf - rand_ys
            end

        end

        # print "y - #{rand_ys} #{rand_yf} x - #{rand_xs} #{rand_xf}, yd - #{rand_yd} xd - #{rand_xd}\n"
        map_obj[names_array[i].to_sym][:rand_ys] = rand_ys
        map_obj[names_array[i].to_sym][:rand_yf] = rand_yf
        map_obj[names_array[i].to_sym][:rand_xs] = rand_xs
        map_obj[names_array[i].to_sym][:rand_xf] = rand_xf
        map_obj[names_array[i].to_sym][:rand_yd] = rand_yd
        map_obj[names_array[i].to_sym][:rand_xd] = rand_xd
        map_obj[names_array[i].to_sym][:direc] = (i % 2 == 0)? 'EW': 'NS';
        map_obj[names_array[i].to_sym][:points] = [[rand_ys,rand_xs],[rand_yf,rand_xf]]
        map_obj[names_array[i].to_sym][:inter] = []
        map_obj[names_array[i].to_sym][:color] = color_array[i]
        inter_create = []

        #x_start - x_finish > 20
        #place station randomly between x_start and x_finish, with y variation
        map[rand_ys][rand_xs] = "\u25ef".colorize(color: color_array[i].to_sym)
        map[rand_yf][rand_xf] = "\u25ef".colorize(color: color_array[i].to_sym)

        #add stations to line with random spacing
        
        case(oddeven)
        when 0
            x_range = Array.new(rand_xf - rand_xs - 10){|i| rand_xs+i+5}
            # print "x_range #{x_range} "
            x_stat = []
            while(low_diff(x_stat) < 5)
                x_stat = [rand_xs,x_range.sample((x_range.length / 5).floor()-1),rand_xf].flatten
            end
            # print "x_stat #{x_stat}\n"  

            x_stat.each_index{|ind|
            # print "ind - #{ind}\n"
                if(ind > 0 && ind < (x_stat.length-1))
                    rand_y_var = nil
                    while(rand_y_var == nil || (rand_ys+rand_y_var) <= 0 || (rand_ys+rand_y_var) >= y)
                        rand_y_var = [-2,-1,-1,0,0,0,0,1,1,2].sample
                    end
                    map[rand_ys+rand_y_var][x_stat[ind]] = "\u25ef".colorize(color: color_array[i].to_sym)
                    map_obj[names_array[i].to_sym][:points].push([rand_ys+rand_y_var,x_stat[ind]])
                end
            }
            

        when 1
            y_range = Array.new(rand_yf - rand_ys - 10){|i| rand_ys+i+5}
            y_stat = []
            while(low_diff(y_stat) < 5)
                y_stat = [rand_ys,y_range.sample((y_range.length / 5).floor()-1),rand_yf].flatten
            end
            # print "y_range #{y_range} y_stat #{y_stat}\n"

            y_stat.each_index{|ind|
                if(ind > 0 && ind < (y_stat.length-1))
                    rand_x_var = nil
                    while(rand_x_var == nil || (rand_xs+rand_x_var) <= 0 || (rand_xs+rand_x_var) >= x)
                        rand_x_var = [-2,-1,-1,0,0,0,0,1,1,2].sample
                    end
                    map[y_stat[ind]][rand_xs+rand_x_var] = "\u25ef".colorize(color: color_array[i].to_sym)
                    map_obj[names_array[i].to_sym][:points].push([y_stat[ind],rand_xs+rand_x_var])
                end
            }
        end
    end

    map_obj.each{ |line_key, line_val|
        if(line_val[:direc] == 'EW')
            #sort by y
            line_val[:points].sort!{|a,b|  a[1] <=> b[1]}
            
        elsif(line_val[:direc] == 'NS')
            #sort by x
            line_val[:points].sort!

        end
        print "points #{line_val[:points]} - dir #{line_val[:direc]}\n".colorize(color: line_val[:color].to_sym)
    }

    # #check if distanced < 2 spaces
    #if close to station on other line, merge. interchange "\u25a0"
    map_obj.each{ |line_comp1_key, line_comp1_val|
        map_obj.each{ |line_comp2_key, line_comp2_val|
            #if the lines are different directions
            if(line_comp1_val[:direc] == 'NS' && line_comp2_val[:direc] == 'EW')
                #check if they intersect at (x,y)
                if((line_comp1_val[:rand_xs] >= line_comp2_val[:rand_xs]-5) && (line_comp1_val[:rand_xs] <= line_comp2_val[:rand_xf]+5)) #line1 x between line2 x's
                    if((line_comp2_val[:rand_ys] >= line_comp1_val[:rand_ys]-5) && (line_comp2_val[:rand_ys] <= line_comp1_val[:rand_yf]+5))    #line2 y between line1 y's
                        line2_inter = line_comp2_val[:rand_ys]
                        line1_inter = line_comp1_val[:rand_xs]
                        map[line2_inter][line1_inter] = "\u25a0"                              #place an intersection on map
                        
                        map_dist(line2_inter,line1_inter, 2).each{|remove_stat|

                            if(line_comp1_val[:points].include?(remove_stat))
                                # print " #{line2_inter},#{line1_inter}  #{remove_stat} delete\n"
                                line_comp1_val[:points].delete(remove_stat)
                                map[remove_stat[0]][remove_stat[1]] = ' '
                            end

                            if(line_comp2_val[:points].include?(remove_stat))
                                # print " #{line2_inter},#{line1_inter}  #{remove_stat} delete\n"
                                line_comp2_val[:points].delete(remove_stat)
                                map[remove_stat[0]][remove_stat[1]] = ' '
                            end
                        }
                        #-------------------if there is a station at intersection already
                        if(line_comp1_val[:points].include?([line2_inter,line1_inter]))
                            line_comp1_val[:points].delete([line2_inter,line1_inter])
                        end
                        if(line_comp2_val[:points].include?([line2_inter,line1_inter]))
                            line_comp2_val[:points].delete([line2_inter,line1_inter])
                        end

                        if !(line_comp1_val[:inter].include?([line2_inter,line1_inter]))        #NS
                            line_comp1_val[:inter].push([line2_inter,line1_inter])              #if intersection not included in line, push new intersection
                            line_comp2_val[:inter].push([line2_inter,line1_inter])               #if intersection not included in line, push new intersection
                            
                            #insert the intesection into right index in points
                            inter_pos1 = 0
                            inter_pos2 = 0
                            line_comp1_val[:points].each{|point|
                                #if next point[y] is less then current point[y]
                                if(point[0] < line2_inter)
                                    #increment counter
                                    inter_pos1 += 1
                                end
                            }
                            line_comp2_val[:points].each{|point|
                                #if next point[y] is less then current point[y]
                                if(point[1] < line1_inter)
                                    #increment counter
                                    inter_pos2 += 1
                                end
                            }
                            line_comp1_val[:points].insert(inter_pos1,[line2_inter,line1_inter])
                            line_comp2_val[:points].insert(inter_pos2,[line2_inter,line1_inter])
                            print "#{line_comp1_key},#{line_comp2_key},#{inter_pos1},#{inter_pos2}\n"
                            inter_create.push([line_comp1_key.to_s,line_comp2_key.to_s,inter_pos1,inter_pos2])
                            # print "points #{line_comp1_val[:points]}\n".colorize(color: line_comp1_val[:color].to_sym)
                            # print "points #{line_comp2_val[:points]}\n".colorize(color: line_comp2_val[:color].to_sym)
                            # print "inter_create #{inter_create}\n"
                        end
                    end
                end
            end
        }
    }

    #------------------------------------loop through each line---------------------------
    #-------------------------create a list of all intersections and their index----------

    map_obj.each{ |line_key, line_val|
        print "points #{line_val[:points]} - dir #{line_val[:direc]}\n".colorize(color: line_val[:color].to_sym)
        #workout distances
        dist = []
        line_val[:points].each_index{|ind|
            if(ind < (line_val[:points].length - 1))
                fin_y = line_val[:points][ind+1][0]
                fin_x = line_val[:points][ind+1][1]
                diff_x = (line_val[:points][ind][1] - line_val[:points][ind+1][1])
                diff_y = (line_val[:points][ind][0] - line_val[:points][ind+1][0])
                # x -5 y 1 EW
                # if EW and y > 0 || y < 0 && diff_x pos
                #add line to point[y,x+1]point[y+1,x+1]
                # print "x #{diff_x} y #{diff_y} dir #{line_val[:direc]}\n"
                mag = diff_x.abs + diff_y.abs
                
                dist.push(mag)
                if(line_val[:direc] == 'EW')
                    while (diff_x > 1 || diff_x < -1)
                        # print "dx #{diff_x}\n"
                        if(diff_y > 0)
                            map[fin_y+diff_y-1][fin_x+diff_x+1] = "\u250d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            map[fin_y+diff_y][fin_x+diff_x+1] = "\u2519".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            diff_y = diff_y-1
                        elsif(diff_y < 0)
                            map[fin_y+diff_y+1][fin_x+diff_x+1] = "\u2515".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            map[fin_y+diff_y][fin_x+diff_x+1] = "\u2511".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            diff_y = diff_y+1
                        else
                            map[fin_y][fin_x+diff_x+1] = "\u257e".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            # print "[#{fin_y},#{fin_x+diff_x+1}]--\n"
                        end
                        diff_x += 1
                    end
                end

                if(line_val[:direc] == 'NS')
                    while (diff_y > 1 || diff_y < -1)
                        # print "dy #{diff_y}\n"
                        # byebug
                        if(diff_x > 0)
                            map[fin_y+diff_y+1][fin_x+diff_x-1] = "\u250d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            map[fin_y+diff_y+1][fin_x+diff_x] = "\u2519".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            diff_x = diff_x - 1
                        elsif(diff_x < 0)
                            map[fin_y+diff_y+1][fin_x+diff_x+1] = "\u2511".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            map[fin_y+diff_y+1][fin_x+diff_x] = "\u2515".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                            diff_x += 1
                        else
                            map[fin_y+diff_y+1][fin_x] = "\u257d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                        end
                        diff_y += 1
                    end
                end
            end
        }
        # print "dist #{dist}\n\n"

        
        Line.new(line_key.to_s, generate_stations(line_val[:points].length), dist, line_val[:direc],line_val[:color])
        
        
    }
    inter_create.each{|inter|
        intersect_lines(Line.all_lines[inter[0]],Line.all_lines[inter[1]],inter[2],inter[3])
    }
    # pp map_obj
    #-------create trains for each line--------
    print "______________________MAP______________________\n"
    map.each{ |line|
        line.each{ |point|
            print point
        }
        print "\n"
    }
end

def show_map
    print "\n"
    Line.all_lines.each{|k,line|
        line.print_line()
    }
end

class TimeError < StandardError
end

class TripError < StandardError
end

testing = (ARGV[0] == "testing")            #get argument to check if to run testing

generate_lines(60,30,6)            #-----------------------------------------------------
show_map()

#Create lines - (name, stations, distances, direction, color)
# District = Line.new("District", generate_stations(6), [8,12,12,4,4], "EW","light_red")
# Northern = Line.new("Northern", generate_stations(5), [8,12,20,4], "NS","light_white")
# Express = Line.new("Express", generate_stations(3), [20,24], "NS","light_blue")
# Victoria = Line.new("Victoria", generate_stations(4), [8,8,8], "EW","light_yellow")
# Picadilly = Line.new("Picadilly", generate_stations(3), [12,16], "EW", "magenta")
# Lonely = Line.new("Lonely", generate_stations(3), [8,4], "EW","light_green")

# print "All lines #{Line.all_lines.interchanges}\n"

# intersect_lines(District,Northern,1,2)
# intersect_lines(Express,Victoria,0,1)
# intersect_lines(District,Express,3,2)
# intersect_lines(Northern,Picadilly,0,0)
# intersect_lines(Express,Picadilly,1,2)

Line.all_lines.each{|k,line|
    # print "#{line.interchanges}\n"
}
# print "All interchanges - #{Station.all_interchange}\n"
# print "All stations - #{Station.all_stations}\n"

#create trains
#train.new(start_point, train_direction,line)

# train1 = Train.new(1, 'E',District)
# train2 = Train.new(3, 'W',District)
# train3 = Train.new(2, 'N',Northern)
# train4 = Train.new(4, 'N',Northern)
# train5 = Train.new(2, 'S',Express, 3)
# train6 = Train.new(2, 'W',Victoria)
# train6 = Train.new(2, 'W', Picadilly)
# train6 = Train.new(1, 'E', Picadilly)

Train.all_trains.each{|train|
    train.cal_time(600)
}

#error if there is no train on line


quit = false

if (testing)                    #test different trip requests
    begin

    print "All stations - #{Station.all_stations}\n"
    print "All interchanges - #{Station.all_interchange}\n"
    print "\n"

    trip1 = Trip.new(100,102,1)                         #same line
    trip2 = Trip.new(100,102,50)                        #same line, differnet time
    trip3 = Trip.new(100,113,1)                         #same line, destination is interchange
    trip4 = Trip.new(100,107,1)                         #different line
    trip5 = Trip.new(108,110,1)                         #different line, origin is interchange
    trip6 = Trip.new(100,117,1)                         #go through 4 different lines
    trip7 = Trip.new(100,119,1)                         #
    trip8 = Trip.new(102,122,1)                         #unreachable station
    trip9 = Trip.new(100,102,1500)                      #same line, time doesn't exist

    Trip.all_trip.each{|trip|
        trip.cal_trip()
    }

    # if error occurs print an error
    rescue TimeError
        print "Invalid time \n"
    rescue TypeError
        print "Type Error \n"
    rescue StandardError
        print "Station number does not exist \n"
    end

end

while !quit
    menu_choice = -1
    print "\n"
    print "Welcome to the Subway Travel App\n"
    print "----------------------------------\n"
    print "Select option: \n"
    print "1 - Search for trip \n"
    print "2 - Look at map\n"
    print "3 - Look at timetable\n"
    print "4 - Quit\n"
    print "----------------------------------\n"

    begin

    menu_choice = STDIN.gets.chomp.to_i                     #get menu input from user
    
    #if NaN generate error
    raise TypeError, "NaN" if(menu_choice == 0)

    rescue TypeError
        print "TypeError - Select menu number\n"
    end

    

    #validate input
    case menu_choice
    when 1
        begin
            print "Origin? "
            origin_choice = STDIN.gets.chomp.to_i               #get origin choice from user
            
            raise TypeError, "NaN" if(origin_choice == 0)                                           #return error if not a number
            raise StandardError, "No number" if(Station.all_stations[origin_choice] == nil)         #return error if station doesn't exist
            
            print "Destination? "
            destination_choice = STDIN.gets.chomp.to_i          #get destination choice from user

            raise TypeError, "NaN" if(destination_choice == 0)                                      #return error if not a number
            raise StandardError, "No number" if(Station.all_stations[destination_choice] == nil)    #return error if station doesn't exist        

            print "Time leaving? "
            time_choice = STDIN.gets.chomp.to_i                 #get time to depart by
            
            raise TimeError, "NaN" if(time_choice == 0)         #return error if not a number

            trip = Trip.new(origin_choice,destination_choice,time_choice)       #create trip object
            trip.cal_trip()                                                     #calculate path
            
            # print "Travel? "
            # travel_choice = STDIN.gets.chomp.downcase
            # if(travel_choice == 'y')
            #     trip.travel()
            # end
            
            #if error occurs print an error and retry
            rescue TypeError
                print "TypeError - Enter the station number\n"
                retry
            rescue TimeError
                print "Invalid time - Enter again\n"
            # rescue StandardError
            #     print "Station number does not exist \n"
            #     retry
        end

    when 2
        show_map()
        
    when 3
        Train.all_trains.each{|train|
            print "Train - #{train.line_name} Line\n"
            print "---------------------------------------\n"
            train.timetable.each{|k,v|
                print "#{k} -> #{v}\n"
            }
            print "---------------------------------------\n"

        }
    when 4
        print "Quiting!\n"
        quit = true
    else
        print "Not a menu item \n"
    end
end