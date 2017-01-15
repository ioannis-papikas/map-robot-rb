#!/usr/bin/env ruby

# This is the main file for running a path finder problem.
# It can be used to get the input from the user or set
# all input manual for the MapRobot class.
#
# The MapRobot takes an input map in text form and transforms it
# to valid and invalid tiles. The valid tile is marked with '.'.
# All other tiles are considered blocks. We use '@' in this example.

# Load the MapRobot file containing the MapRobot and XYLoc classes
load 'MapRobot.rb'

# Get input from the user.
# In this example we set the values manually
# to avoid errors for testing
#
# If you want to prompt the user, uncomment the following lines
# and get variable values from the user
# print "Map Width:"
# width = gets.chomp
width = 20
# print "Map height:"
# height = gets.chomp
height = 8
# print "Provide map file:"
# mapFile = gets.chomp
mapFile = "minimap.map"

# Initialize map robot
robot = MapRobot.new(mapFile, width.to_i, height.to_i)

# Uncomment this line to draw the map for visualization
# robot.drawMap()

# Define start and goal points for path search.
# Again you can get the input from the user.
# Below is a testing problem (considered complex) with a quite long path.
startPoint = XYLoc.new(5, 5)
endPoint = XYLoc.new(13, 5)

# Find the path between the start and the gol point
path = robot.findPath(startPoint, endPoint)

# Uncomment this line draw the map
# including start, goal point and path (if any)
 robot.drawMapPath(startPoint, endPoint, path)