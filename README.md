# Software Development Plan

## Purpose and Scope
### what the application will do, what problem does it solve, target audience, how they will use it (300 - 500 words)

My idea for the terminal project is to create an app for a subway. The purpose of this app is to help comuters in travelling on the right train.

The program will ask the user for a origin and destination and calculate the path that they have to take

The user will get information on what time to leave the platform, how many stops before changeover or destination, what time they will arrive and the cost of the ticket.

The map will show and update (clear screen and reprint) to show the animation of the user travelling from the origin to the destination.

the target audience for this app will be comuters travelling on the subway. The app will help them to decide what time to leave and which train to catch, by the input that they provide.

### List of features (300 words)

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

print the menu
user selects search for trip, display map, timetable
When searching for trip -> user input origin, destination, time to depart or arrive by

### Control Flow Diagram

img


# Status Updates
## Update 1
    I have had trouble in figuring out how to implement the Trains in the program. My idea is to have the Trains be a child of each of the lines that they are assigned to. Just figuring out how to calculate the timetables for each train. I think that I can write a function in the Train object and access the varibles from the Line object

    Another problem that I am having is trouble with searching for stations in all_stations hash. I have a function called search_station that passes in keys to read the hash. I recieved an error saying 'undefined local varible or method all_stations'. I have solved this by passing the all_stations as a argument of the function.

## Update 2

    I encounterd a problem when creating the train objects. When it is created it places itself at a station and given a direction. The error had occured when I had placed the Train at the last station on a 'NS' line with a direction going 'S'. I plan to correct this problem by changing the direction accordingly when the Train object is initialized.

    I have completed most of the MVP features now. So I will go back through all of the objects and test edge cases or incorrect values. 

https://medium.com/@alexleybourne/text-to-speech-in-ruby-using-gems-61e6d17b7acf
# Help File
### Steps to install

### Dependencies

### explanation of features

### testing