require "faker"
require_relative "./classes/Line.rb"
require_relative "./classes/Train.rb"
require_relative "./classes/Station.rb"
require_relative "./classes/Trip.rb"


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

def show_map
    print "\n"
    Line.all_lines.each{|k,line|
        line.print_line()
    }
end

class TimeError < StandardError
end

testing = (ARGV[0] == "testing")            #get argument to check if to run testing

#Create lines - (name, stations, distances, direction, color)
District = Line.new("District", generate_stations(6), [8,12,12,4,4], "EW","light_red")
Northern = Line.new("Northern", generate_stations(5), [8,12,20,4], "NS","light_white")
Express = Line.new("Express", generate_stations(3), [20,24], "NS","light_blue")
Victoria = Line.new("Victoria", generate_stations(4), [8,8,8], "EW","light_yellow")

Lonely = Line.new("Lonely", generate_stations(3), [8,4], "EW","light_green")

# print "All lines #{Line.all_lines}\n"

intersect_lines(District,Northern,1,2)
intersect_lines(Express,Victoria,0,1)
intersect_lines(District,Express,3,2)

#create trains
#train.new(start_point, train_direction,line)

train1 = Train.new(1, 'E',District)
train2 = Train.new(3, 'W',District)
train3 = Train.new(2, 'N',Northern)
train4 = Train.new(4, 'N',Northern)
train5 = Train.new(2, 'S',Express, 3)
train6 = Train.new(2, 'W',Victoria)

Train.all_trains.each{|train|
    train.cal_time(1000)
}

#error if there is no train on line

show_map()
quit = false

if (testing)                    #test different trip requests
    begin

    print "All stations - #{Station.all_stations}\n"
    print "All interchanges - #{Station.all_interchange}\n"
    print "\n"

    trip1 = Trip.new(100,102,1)                       #same line
    trip2 = Trip.new(100,102,50)                      #same line, differnet time
    trip3 = Trip.new(100,113,1)                       #same line, destination is interchange
    trip4 = Trip.new(100,112,1)                       #different line
    trip5 = Trip.new(113,106,1)                       #different line, origin is interchange
    trip6 = Trip.new(106,117,1)                       #go through 4 different lines
    trip7 = Trip.new(102,120,1)                       #unreachable station
    trip8 = Trip.new(100,102,1500)                    #same line, time doesn't exist

    Trip.all_trip.each{|trip|
        trip.cal_trip()
    }

    # if error occurs print an error
    rescue TimeError
        print "Invalid time \n"
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

            #if error occurs print an error and retry
            rescue TypeError
                print "TypeError - Enter the station number\n"
                retry
            rescue TimeError
                print "Invalid time - Enter again\n"
            rescue StandardError
                print "Station number does not exist \n"
                retry
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