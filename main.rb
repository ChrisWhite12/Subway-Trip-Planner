#   ------Objects-----
#   Train obj
#       - starting point
#       - direction -> (north-bound, west-bound)
#       - cal_time()    -> calculate time train will arrive at each station
#
#   Line obj
#       - station names
#       - time to travel to each
#
#   Station obj
#       - price to travel to
#
#   gems to use     colorize, Faker, Rspec? maybe

require "faker"
require "espeak"
require_relative "./classes/Line.rb"
require_relative "./classes/Train.rb"
require_relative "./classes/Station.rb"
require_relative "./classes/Trip.rb"

include ESpeak

speech = Speech.new("Hallo Welt", voice: "de")
speech.save("hello-de.mp3") # invokes espeak + lame
speech.speak()

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
        station_arr.push(Station.new(Faker::Address.city))
    end
    return station_arr
end

def show_map
    print "\n"
    
    District.print_line()
    Northern.print_line()
    Express.print_line()
    Victoria.print_line()
    Lonely.print_line()

end

testing = (ARGV[0] == "testing")

#Create lines
District = Line.new("District", generate_stations(6), [2,3,3,1,1], "EW","light_red")
Northern = Line.new("Northern", generate_stations(5), [2,3,5,1], "NS","light_white")
Express = Line.new("Express", generate_stations(3), [5,6], "NS","light_blue")
Victoria = Line.new("Victoria", generate_stations(4), [2,2,2], "EW","light_yellow")

Lonely = Line.new("Lonely", generate_stations(3), [2,1], "EW","light_green")

# print "All lines #{Line.all_lines}\n"


intersect_lines(District,Northern,1,2)
intersect_lines(Express,Victoria,0,1)
intersect_lines(District,Express,3,2)

#create trains
#train.new(start_point, train_direction)

train1 = Train.new(1, 'E',District)
train1.cal_time()
# puts train1.timetable

train2 = Train.new(3, 'W',District)
train2.cal_time()
# puts train2.timetable

train3 = Train.new(2, 'N',Northern)
train3.cal_time()
# puts train3.timetable

train4 = Train.new(4, 'N',Northern)
train4.cal_time()
# puts train4.timetable

train5 = Train.new(2, 'S',Express)      #if put South error
train5.cal_time()
# puts train5.timetable

train6 = Train.new(2, 'W',Victoria)      #if put South error
train6.cal_time()
# puts train6.timetable

#error if there is no train on line

show_map()
quit = false

if (testing)
    print "All stations - #{Station.all_stations}\n"
    print "All interchanges - #{Station.all_interchange}\n"
    print "\n"

    trip1 = Trip.new(100,102)
    trip1.cal_trip()
    trip2 = Trip.new(100,113)
    trip2.cal_trip()
    trip3 = Trip.new(100,112)
    trip3.cal_trip()
    trip4 = Trip.new(106,100)
    trip4.cal_trip()
    trip5 = Trip.new(113,106)         #starting at interchange
    trip5.cal_trip()
    trip6 = Trip.new(106,117)
    trip6.cal_trip()
    trip6 = Trip.new(102,120)
    trip6.cal_trip()
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
    menu_choice = STDIN.gets.chomp.to_i

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
        origin_choice = STDIN.gets.chomp.to_i
        
        raise TypeError, "NaN" if(origin_choice == 0)
        raise StandardError, "No number" if(Station.all_stations[origin_choice] == nil)
        
        print "Destination? "
        destination_choice = STDIN.gets.chomp.to_i

        raise TypeError, "NaN" if(destination_choice == 0)
        raise StandardError, "No number" if(Station.all_stations[destination_choice] == nil)
        
        #if NaN generate error
        rescue TypeError
            print "TypeError - Enter the station number\n"
            retry
        rescue StandardError
            print "Station number does not exist \n"
            retry
        end
        trip = Trip.new(origin_choice,destination_choice)
        trip.cal_trip()

    when 2
        print "look at map\n"
        show_map()
        
    when 3
        print "timetable\n"
    when 4
        print "quiting\n"
        quit = true
    else
        print "Not a menu item \n"
    end
end