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

District.print_line()
Northern.print_line()
Express.print_line()
Victoria.print_line()