# Software Development Plan

## Purpose and Scope
### what the application will do, what problem does it solve, target audience, how they will use it (300 - 500 words)

My idea for the terminal project is to create an app for a subway. The purpose of this app is to help comuters in travelling on the right train. The program will ask the user for a origin and destination, calculate for the user what time to leave the platform, how many stops before changeover or destination, what time they will arrive and the cost of the ticket. There will be a simple map such as below to remove the complexity of figuring out mutiple paths.

           o------o-------o
                          |            o
                          |            |
                          |            |
                  o-------o------------o--o
                          |            |
                          |            o
                          o

The map will update (clear screen and reprint) to show the animation of the user travelling

the target audience for this app will be comuters travelling on the subway. The app will help them to decide what time to leave and which train to catch. When the app is started the user will input their starting location and the destination. Also that time in which they would like to Depart By or Arrive By.



### List of features (300 words)

generate lines, stations and trains
take input for the user and calculate the path to destination

### Outline user interaction

input origin, destination, time to depart or arrive by

### Control Flow Diagram

img


# Status Updates
## Update 1
    I have had trouble in figuring out how to implement the Trains in the program. My idea is to have the Trains be a child of each of the lines that they are assigned to. Just figuring out how to calculate the timetables for each train. I think that I can write a function in the Train object and access the varibles from the Line object

    having trouble with searching for stations in all_stations hash
    have a function called search_station
    passes in key values 
    the error comes up with undefined local varible or method all_stations
    can access the all_stations varible by print key values
## Update 2


# Help File
### Steps to install

### Dependencies

### explanation of features

### testing