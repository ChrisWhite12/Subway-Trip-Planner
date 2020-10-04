require "faker"
require "tts"
require "byebug"
require_relative "./classes/Line.rb"
require_relative "./classes/Train.rb"
require_relative "./classes/Station.rb"
require_relative "./classes/Trip.rb"
require_relative "./classes/Main_map.rb"


# print "#{String.color_samples}\n"

class TimeError < StandardError
end

class TripError < StandardError
end

class ADError < StandardError
end

testing = (ARGV[0] == "testing")            #get argument to check if to run testing


#error if there is no train on line


quit = false

if (testing)                    #test different trip requests
    begin

    print "begin testing\n"
    main_map = Main_map.new(50,40)
    
    #Create lines - (name, stations, distances, direction, color)
    District = Line.new("District", main_map.generate_stations(6), [8,12,12,4,4], "EW","light_red",[12,0])
    Northern = Line.new("Northern", main_map.generate_stations(5), [8,4,6,4], "NS","light_white",[0,8])
    Express = Line.new("Express", main_map.generate_stations(3), [10,14], "NS","light_blue",[12,32])
    Victoria = Line.new("Victoria", main_map.generate_stations(4), [8,8,8], "EW","light_yellow",[36,24])
    Picadilly = Line.new("Picadilly", main_map.generate_stations(3), [10,14], "EW", "magenta",[22,8])
    Lonely = Line.new("Lonely", main_map.generate_stations(3), [8,4], "EW","light_green",[14,14])
    
    main_map.intersect_lines(District,Northern,1,2)
    main_map.intersect_lines(Express,Victoria,0,1)
    main_map.intersect_lines(District,Express,3,2)
    main_map.intersect_lines(Northern,Picadilly,0,0)
    main_map.intersect_lines(Express,Picadilly,1,2)
    
    main_map.generate_test_lines()

    train1 = Train.new(1, 'E',District)
    train2 = Train.new(3, 'W',District)
    train3 = Train.new(2, 'N',Northern)
    train4 = Train.new(4, 'N',Northern)
    train5 = Train.new(2, 'S',Express, 3)
    train6 = Train.new(2, 'E',Victoria)
    train8 = Train.new(1, 'E', Picadilly)

    Train.all_trains.each{|train|
        train.cal_time(600)
    }
    # print "after gen trains\n"

    
    # pp train1.timetable
    # pp train2.timetable

    # pp train5.timetable
    # pp train6.timetable

    print "All stations - #{Station.all_stations}\n"
    print "All interchanges - #{Station.all_interchange}\n"
    print "\n"

    trip1 = Trip.new(100,102,1)                         #same line
    trip2 = Trip.new(100,102,50)                        #same line, differnet time
    trip3 = Trip.new(100,113,1)                         #same line, destination is interchange
    trip4 = Trip.new(100,107,1)                         #different line
    trip5 = Trip.new(108,110,1)                         #different line, origin is interchange
    trip6 = Trip.new(100,117,89)                         #go through 4 different lines
    trip7 = Trip.new(100,117,202,'A')                         #go through 4 different lines
    trip8 = Trip.new(100,119,1)                         #Picadilly Line
    # trip9 = Trip.new(102,122,1)                         #unreachable station
    trip10 = Trip.new(100,102,10,'A')                      #same line, time doesn't exist

    Trip.all_trip.each{|trip|
        trip.cal_trip()
    }

    main_map.show_map()

    # if error occurs print an error
    rescue TimeError
        print "Invalid time \n"
    rescue TypeError
        print "Type Error \n"
    rescue StandardError
        print "Station number does not exist \n"
    end
else

    main_map = Main_map.new(80,40)
    main_map.generate_lines(6)            
    # pp main_map
    main_map.show_map()

    Train.all_trains.each{|train|
        train.cal_time(600)
    }



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

            print "Arrive by or Depart by (A/D)? "
            arrive_depart = STDIN.gets.chomp    
            raise ADError, "Not A or D" if(arrive_depart != 'A' && arrive_depart != 'D') 


            print "Time #{arrive_depart == 'D' ? 'Departing' : 'Arriving'} ?"
            time_choice = STDIN.gets.chomp.to_i                 #get time to depart by
            
            raise TimeError, "NaN" if(time_choice == 0)         #return error if not a number

                     

            trip = Trip.new(origin_choice,destination_choice,time_choice,arrive_depart)       #create trip object
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
                retry
            rescue ADError
                print "Enter A or D\n"
                retry
            rescue StandardError
                print "Station number does not exist \n"
        end

    when 2
        main_map.show_map()
        
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