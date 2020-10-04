require "colorize"
require_relative "./Line.rb"
require_relative "./Train.rb"


class Main_map
    attr_accessor :line_info, :map_arr
    @@all_maps = []

    def initialize (size_x, size_y)
        @size_x = size_x
        @size_y = size_y
        @map_arr = Array.new(size_y){Array.new(size_x,' ')}
        @line_info = {}
        @@all_maps.push(self)   
    end

    def show_map()

        print "______________________MAP______________________\n"
        @map_arr.each{ |line|
            line.each{ |point|
                print point
            }
            print "\n"
        }
    
        print "\n"
        Line.all_lines.each{|k,line|
            line.print_line()
        }
    end

    def all_maps
        @@all_maps
    end

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

    def generate_test_lines()
        ind = 0
        Line.all_lines.each{|k,line|
            # print "#{line.start_xy}, #{ind}\n"
            #print O at start
            start_x = line.start_xy[1]
            start_y = line.start_xy[0]
            # print "x - #{start_x}, y - #{start_y}\n"

            @map_arr[start_y][start_x] = "\u25ef".colorize(color: line.color)
            #for each distance
            line.distances.each{|dist|
                #print - for on map distance
                # print "in distances.each #{dist}\n"
                if(line.direction == 'EW')
                    # print "EW\n"
                    for i in 1..dist
                        @map_arr[start_y][start_x+i] = "\u257e".encode('utf-8').colorize(color: line.color.to_sym)
                    end 
                    @map_arr[start_y][start_x+i] = "\u25ef".encode('utf-8')
                    start_x += dist
                elsif(line.direction == 'NS')
                    # print "NS\n"
                    for i in 1..dist
                        @map_arr[start_y+i][start_x] = "\u257d".encode('utf-8').colorize(color: line.color.to_sym)
                    end 
                    @map_arr[start_y+1][start_x] = "\u25ef".encode('utf-8')
                    start_y += dist
                end
            }
            ind += 1;
        }
        # print "end of gen_test_lines \n"

        # pp @map_arr
    end

    def generate_lines(lines)
        #start with a empty 100x100 grid
        # main_map = Array.new(y){Array.new(x,' ')}
        color_array = ["red","white","blue","yellow","magenta","green"]
        names_array = ["District","Northern","Express","Victoria","Picadilly","Central"]
        lines_NS_xpos = [0]
        lines_EW_ypos = [0]
    
        #for 3..6 lines for NS and EW
        for i in 0...(lines) do
            # print "i - #{i}\n"
            @line_info[names_array[i].to_sym] = {}
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
                    rand_ys = (rand 1...@size_y).floor()
                    y_spacing = [rand_ys-3,rand_ys-2, rand_ys-1, rand_ys, rand_ys+1, rand_ys+2,rand_ys+3]
                    # print "ys #{rand_ys}\n"
                    # print "!!#{lines_EW_ypos & y_spacing} -- #{y_spacing}\n"
                end
                rand_yf = rand_ys
                lines_EW_ypos.push(rand_ys)
                #random number for x_start
    
                while (rand_xd) < (@size_x/2)
                    rand_xs = (rand 1...(@size_x/2)).floor()
                    #random number for x_finish
                    rand_xf = (rand (@size_x/2)...@size_x).floor()
                    rand_xd = rand_xf - rand_xs
                end
    
            when 1      #when NS
                while !(lines_NS_xpos & x_spacing == [])
                    rand_xs = (rand 1...@size_x).floor()
                    x_spacing = [rand_xs-3,rand_xs-2, rand_xs-1, rand_xs, rand_xs+1, rand_xs+2,rand_xs+3]
                end
                lines_NS_xpos.push(rand_xs)
                rand_xf = rand_xs
                #random number for x_start
    
                while (rand_yd) < (@size_y/2)
                    rand_ys = (rand 1...(@size_y/2)).floor()
                    #random number for x_finish
                    rand_yf = (rand (@size_y/2)...@size_y).floor()
                    rand_yd = rand_yf - rand_ys
                end
    
            end
    
            # print "y - #{rand_ys} #{rand_yf} x - #{rand_xs} #{rand_xf}, yd - #{rand_yd} xd - #{rand_xd}\n"
            @line_info[names_array[i].to_sym][:rand_ys] = rand_ys
            @line_info[names_array[i].to_sym][:rand_yf] = rand_yf
            @line_info[names_array[i].to_sym][:rand_xs] = rand_xs
            @line_info[names_array[i].to_sym][:rand_xf] = rand_xf
            @line_info[names_array[i].to_sym][:rand_yd] = rand_yd
            @line_info[names_array[i].to_sym][:rand_xd] = rand_xd
            @line_info[names_array[i].to_sym][:direc] = (i % 2 == 0)? 'EW': 'NS';
            @line_info[names_array[i].to_sym][:points] = [[rand_ys,rand_xs],[rand_yf,rand_xf]]
            @line_info[names_array[i].to_sym][:inter] = {}
            @line_info[names_array[i].to_sym][:color] = color_array[i]
            inter_create = []
    
            #x_start - x_finish > 20
            #place station randomly between x_start and x_finish, with y variation
            @map_arr[rand_ys][rand_xs] = "\u25ef".colorize(color: color_array[i].to_sym)
            @map_arr[rand_yf][rand_xf] = "\u25ef".colorize(color: color_array[i].to_sym)
    
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
                        while(rand_y_var == nil || (rand_ys+rand_y_var) <= 0 || (rand_ys+rand_y_var) >= @size_y)
                            rand_y_var = [-2,-1,-1,0,0,0,0,1,1,2].sample
                        end
                        @map_arr[rand_ys+rand_y_var][x_stat[ind]] = "\u25ef".colorize(color: color_array[i].to_sym)
                        @line_info[names_array[i].to_sym][:points].push([rand_ys+rand_y_var,x_stat[ind]])
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
                        while(rand_x_var == nil || (rand_xs+rand_x_var) <= 0 || (rand_xs+rand_x_var) >= @size_x)
                            rand_x_var = [-2,-1,-1,0,0,0,0,1,1,2].sample
                        end
                        @map_arr[y_stat[ind]][rand_xs+rand_x_var] = "\u25ef".colorize(color: color_array[i].to_sym)
                        @line_info[names_array[i].to_sym][:points].push([y_stat[ind],rand_xs+rand_x_var])
                    end
                }
            end
        end
    
        # #check if distanced < 2 spaces
        #if close to station on other line, merge. interchange "\u25a0"
        @line_info.each{ |line_comp1_key, line_comp1_val|
            @line_info.each{ |line_comp2_key, line_comp2_val|
                #if the lines are different directions
                if(line_comp1_val[:direc] == 'NS' && line_comp2_val[:direc] == 'EW')
                    #check if they intersect at (x,y)
                    if((line_comp1_val[:rand_xs] >= line_comp2_val[:rand_xs]-5) && (line_comp1_val[:rand_xs] <= line_comp2_val[:rand_xf]+5)) #line1 x between line2 x's
                        if((line_comp2_val[:rand_ys] >= line_comp1_val[:rand_ys]-5) && (line_comp2_val[:rand_ys] <= line_comp1_val[:rand_yf]+5))    #line2 y between line1 y's
                            line2_inter = line_comp2_val[:rand_ys]
                            line1_inter = line_comp1_val[:rand_xs]
                            @map_arr[line2_inter][line1_inter] = "\u25a0"                              #place an intersection on map
                            
                            map_dist(line2_inter,line1_inter, 2).each{|remove_stat|
    
                                if(line_comp1_val[:points].include?(remove_stat))
                                    # print " #{line2_inter},#{line1_inter}  #{remove_stat} delete\n"
                                    line_comp1_val[:points].delete(remove_stat)
                                    @map_arr[remove_stat[0]][remove_stat[1]] = ' '
                                end
    
                                if(line_comp2_val[:points].include?(remove_stat))
                                    # print " #{line2_inter},#{line1_inter}  #{remove_stat} delete\n"
                                    line_comp2_val[:points].delete(remove_stat)
                                    @map_arr[remove_stat[0]][remove_stat[1]] = ' '
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
                                line_comp1_val[:inter][line_comp2_key]=([line2_inter,line1_inter])              #if intersection not included in line, push new intersection
                                line_comp2_val[:inter][line_comp1_key]=([line2_inter,line1_inter])               #if intersection not included in line, push new intersection
    
                                line_comp1_val[:points].push([line2_inter,line1_inter])
                                line_comp2_val[:points].push([line2_inter,line1_inter])
                                # print "points #{line_comp1_val[:points]}\n".colorize(color: line_comp1_val[:color].to_sym)
                                # print "points #{line_comp2_val[:points]}\n".colorize(color: line_comp2_val[:color].to_sym)
                                print "inter #{line_comp1_val[:inter]}\n"
                            end
                        end
                    end
                end
            }
        }
        
        @line_info.each{ |line_key, line_val|              #sort the station points 
            if(line_val[:direc] == 'EW')
                #sort by y
                line_val[:points].sort!{|a,b|  a[1] <=> b[1]}
    
            elsif(line_val[:direc] == 'NS')
                #sort by x
                line_val[:points].sort!
            end
        }
    
        inter_done = []                             #all intersections that have been processed
        @line_info.each{ |line_key, line_val|
            line_val[:inter].each{|k,v|
                if (inter_done & [v] == [])         #if not processed
                    # print "processing #{v} -- inter_done #{inter_done}\n"
                    inter_done.push(v)              #push intersection to processed array
                    inter_create.push([line_key.to_s,k.to_s,line_val[:points].index(v),@line_info[k][:points].index(v)])
                end
            }
            print "points #{line_val[:points]} - dir #{line_val[:direc]}\n".colorize(color: line_val[:color].to_sym)            
        }
    
        
        pp inter_create
    
        @line_info.each{ |line_key, line_val|              #workout distances and print lines on map       
            
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
                                @map_arr[fin_y+diff_y-1][fin_x+diff_x+1] = "\u250d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                @map_arr[fin_y+diff_y][fin_x+diff_x+1] = "\u2519".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                diff_y = diff_y-1
                            elsif(diff_y < 0)
                                @map_arr[fin_y+diff_y+1][fin_x+diff_x+1] = "\u2515".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                @map_arr[fin_y+diff_y][fin_x+diff_x+1] = "\u2511".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                diff_y = diff_y+1
                            else
                                @map_arr[fin_y][fin_x+diff_x+1] = "\u257e".encode('utf-8').colorize(color: line_val[:color].to_sym)  
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
                                @map_arr[fin_y+diff_y+1][fin_x+diff_x-1] = "\u250d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                @map_arr[fin_y+diff_y+1][fin_x+diff_x] = "\u2519".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                diff_x = diff_x - 1
                            elsif(diff_x < 0)
                                @map_arr[fin_y+diff_y+1][fin_x+diff_x+1] = "\u2511".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                @map_arr[fin_y+diff_y+1][fin_x+diff_x] = "\u2515".encode('utf-8').colorize(color: line_val[:color].to_sym)  
                                diff_x += 1
                            else
                                @map_arr[fin_y+diff_y+1][fin_x] = "\u257d".encode('utf-8').colorize(color: line_val[:color].to_sym)  
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
        # pp main_map.line_info
        
        
        Line.all_lines.each{|line_key,line_val|
            p line_val.direction
            p line_val.stations.length-1
            rand_1 = rand 0...(line_val.stations.length-1)
            rand_2 = rand 0...(line_val.stations.length-1)
            direc_rand = (line_val.direction == 'NS')? (['N','S'].sample()) : (['E','W'].sample());
            Train.new(rand_1, direc_rand,Line.all_lines[line_key.to_s])
            Train.new(rand_2, direc_rand,Line.all_lines[line_key.to_s])
        }
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

end