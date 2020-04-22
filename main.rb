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
require_relative "./classes/Line.rb"
require_relative "./classes/Train.rb"
require_relative "./classes/Station.rb"

all_lines = []

def search_station(data,search1,search2)
    data.each{|line|
        line.stations.each{|station|
            if (station.station_name == search1)
                print "Origin - #{station.station_name} - #{line.line_name} Line - interchange #{station.isInterchange} \n"
            elsif(station.station_name == search2)
                print "Destination - #{station.station_name} - #{line.line_name} Line - interchange #{station.isInterchange} #{station.color}\n"
            end
        }
    }

    #search for origin and destination 

        #share the same line?
        #trip = [origin,destination]
    #start at origin
    #look at the intersection(s)
        #share the same line as destination?
        #Yes
        #trip = [origin, intersection, destination]
        #No

    #
end

def intersect_lines(line1,line2,stat1,stat2)
    line1.stations[stat1] = line2.stations[stat2]
    line1.stations[stat1].isInterchange = true
    line2.stations[stat2].isInterchange = true
    print "intersection --- #{line2.stations[stat2].station_name}\n"
    
    #remove stations that become intersections

end

def generate_stations(num)
    station_arr = []
    num.times do
        station_arr.push(Station.new(Faker::Address.city))
    end
    return station_arr
end


District = Line.new("District", generate_stations(6), [2,3,3,1,1], "EW","light_red")
Northern = Line.new("Northern", generate_stations(5), [2,3,5,1], "NS","light_white")
Express = Line.new("Express", generate_stations(3), [5,6], "NS","light_blue")
Victoria = Line.new("Victoria", generate_stations(4), [2,2,2], "EW","light_yellow")

all_lines = [District,Northern,Express,Victoria]

intersect_lines(District,Northern,1,2)
intersect_lines(Express,Victoria,0,1)
intersect_lines(District,Express,4,2)

District.print_line()
Northern.print_line()
Express.print_line()
Victoria.print_line()
print "\n"

print "S.all stations - #{Station.all_stations}\n"

quit = false

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
    menu_choice = gets.chomp.to_i

    #if NaN generate error
    raise TypeError, "NaN" if(menu_choice == 0)

    rescue TypeError
        print "TypeError - Select menu number\n"
    end

    #validate input
    if(menu_choice == 1)
        begin

        print "Origin? "
        origin_choice = gets.chomp.to_i

        raise TypeError, "NaN" if(origin_choice == 0)

        print "Destination? "
        destination_choice = gets.chomp.to_i

        raise TypeError, "NaN" if(destination_choice == 0)
        
        #if NaN generate error
        rescue TypeError
            print "TypeError - Enter the station number\n"
        end
        search_station(all_lines,Station.all_stations[origin_choice],Station.all_stations[destination_choice])

    elsif(menu_choice == 2)
        print "look at map\n"
    elsif(menu_choice == 3)
        print "timetable\n"
    elsif(menu_choice == 4)
        print "quiting\n"
        quit = true
    end
    #make menu a case statement
end