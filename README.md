# Software Development Plan

## Purpose and Scope
My idea for the terminal project is to create an app for a subway. The purpose of this app is to help comuters in travelling on the right train. The program will ask the user for a origin, destination and departure time which will calculate the path that they have to take.

The user will get information on what time to leave the platform, how many stops before changeover or destination, what time they will arrive and the cost of the ticket. The map will show and update (clear screen and reprint) to show the animation of the user travelling from the origin to the destination.

The target audience for this app will be comuters travelling on the subway. The app will help them to decide what time to leave and which train to catch, by the input that they provide.

### List of features

generate lines, stations and trains
take input for the user and calculate the path to destination

There will be a simple map such as below to remove the complexity of figuring out mutiple paths.

           o------o-------o
                          |            o
                          |            |
                          |            |
                  o-------o------------o--o
                          |            |
                          |            o
                          o

### Outline user interaction

When the program starts the map and menu is printed. The user selects search for trip, display map, timetable or quit by typing numbers. When searching for trip the user inputs origin, destination, time to depart. The program takes these inputs, outputs the directions for the trip and returns back to the menu.

The other menu options are to display the map, which prints the map again. The timetable option prints the timetables for each train. Lastly, the quit option breaks of the program loop and quits.

With all of these inputs, there is validation and error checking. 

### Control Flow Diagram

![Trello](./docs/Trello1.png)

![Trello](./docs/Trello2.png)


# Status Updates
## Update 1
    I have had trouble in figuring out how to implement the Trains in the program. My idea is to have the Trains be a child of each of the lines that they are assigned to. Just figuring out how to calculate the timetables for each train. I think that I can write a function in the Train object and access the varibles from the Line object

    Another problem that I am having is trouble with searching for stations in all_stations hash. I have a function called search_station that passes in keys to read the hash. I recieved an error saying 'undefined local varible or method all_stations'. I have solved this by passing the all_stations as a argument of the function.

## Update 2

    I encounterd a problem when creating the train objects. When it is created it places itself at a station and given a direction. The error had occured when I had placed the Train at the last station on a 'NS' line with a direction going 'S'. I plan to correct this problem by changing the direction accordingly when the Train object is initialized.

## Update 3

    I had some trouble trying to work out how to calculate the path to the destination. I had created a diagram to help me through this problem:

    ![Path Calculate](./docs/Path_cal.png)

    In this example, there is a list of stations that are intersections (s1,s2,etc.) and the list of paths that they connect ([a,b],[a,c]) respectivly. The path to be calculated is to go from path 'a' to 'z', so the program start with path 'a'. Each of the intersections are looked at to see if any of them include 'a' and are merged into the array. The process repeats by looking at the intersections and searching for the last item of each path (in this case 'b' and 'c'). The intersections that have already been used have to be ignored to prevent contiuous looping (eg. [a,b,a,b,a,b...]). All of this repeats until 'z' is found.

# Help File
### Steps to install
    To be able to run the ruby program, Ruby has to be installed
    
    install gems
    colorize
    faker

### Explanation of features
    display map
    display timetable
    searching for trip
        -calculating the path to take
        -calculating the times the trains will arrive at each station

### Testing
    
    Testing is run by writing testing as an argument when starting.

    >ruby main.rb testing

    For the Test, different types of paths and times are input into trip object and the path is calculated. The tests are given below:

    trip1 = Trip.new(100,102,1)                       #same line
    trip1.cal_trip()
    trip1 = Trip.new(100,102,50)                      #same line, differnet time
    trip1.cal_trip()
    trip2 = Trip.new(100,113,1)                       #same line, destination is interchange
    trip2.cal_trip()
    trip3 = Trip.new(100,112,1)                       #different line
    trip3.cal_trip()
    trip5 = Trip.new(113,106,1)                       #different line, origin is interchange
    trip5.cal_trip()
    trip6 = Trip.new(106,117,1)                       #go through 4 different lines
    trip6.cal_trip()
    trip6 = Trip.new(102,120,1)                       #unreachable station
    trip6.cal_trip()
    trip7 = Trip.new(100,102,1500)                    #same line, time doesn't exist
    trip7.cal_trip()