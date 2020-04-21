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

def intersect_lines(line1,line2,stat1,stat2)
    line1.stations[stat1] = line2.stations[stat2]
    print "#{line2.stations[stat2]}\n"
end

station1 = []
station2 = []
station3 = []
station4 = []

6.times do
    station1.push(Faker::Address.city)
end
5.times do
    station2.push(Faker::Address.city)
end
3.times do
    station3.push(Faker::Address.city)
end
4.times do
    station4.push(Faker::Address.city)
end

District = Line.new("District", station1, [2,3,3,1,1], "EW")
Northern = Line.new("Northern", station2, [2,3,5,1], "NS")
Express = Line.new("Express", station3, [5,6], "NS")
Victoria = Line.new("Victoria", station4, [2,2,2], "EW")

intersect_lines(District,Northern,1,2)
intersect_lines(Express,Victoria,0,1)

District.print_line()
Northern.print_line()
Express.print_line()
Victoria.print_line()



# Train1 = Train.new()

quit = false

while !quit
    choice = 0
    print "Welcome to the Subway Travel App\n"
    print "----------------------------------\n"
    print "Select option: \n"
    print "1 - Search for trip \n"
    print "2 - Look at map\n"
    print "3 - Look at timetable\n"
    print "4 - Quit\n"
    print "----------------------------------\n"

    choice = gets.chomp.to_i

    #validate input
    if(choice == 1)
        print "search for trip\n"
    elsif(choice == 2)
        print "look at map\n"
    elsif(choice == 3)
        print "timetable\n"
    elsif(choice == 4)
        print "quiting\n"
        quit = true
    end
end