# Class: MapRobot
#
# This class is responsible for representing a text-based map
# and finding paths between two valid points.
class MapRobot
    # This class initializes the map robot with a map.
    # The map is in text representation where each character
    # is obstacle and only '.' is a valid space.
    def initialize(filePath, width, height)
        # Initialize map text content to parse later
        @mapTextContent = ""
        
        # Open map file
        f = File.open(filePath, "r")
        f.each_line do |line|
            @mapTextContent += line
        end
        f.close
        
        # Set map dimensions
        @width = width
        @height = height
        
        # Initialize mapArray
        # We are using a single array for all points.
        # We could easily use a 2-dimensions array in the same way
        @mapArray = Array.new(@width * @height, 0)
        
        # Parse the map text content and transform to array
        rows = @mapTextContent.strip().split("\n")
        y=0
        for row in rows
            # Get each row context
            x=0
            row.each_char {|c|
                self.setMapValue(x, y, c == '.' ? 1 : 0)
                x += 1
            }
            y += 1
        end
    end
    
    # Set a map value given x and y
    def setMapValue(x, y, value)
        index = self.getMapIndex(x, y)
        return @mapArray[index] = value;
    end
    
    # Get a map value given x and y
    def getMapValue(x, y)
        index = self.getMapIndex(x, y)
        return @mapArray[index];
    end
    
    # Get a map 2D index to 1D
    def getMapIndex(x, y)
        return y * @width + x;
    end
    
    # Get a xyLoc 2D index to 1D
    def getXYIndex(s)
        return s.y * @width + s.x;
    end
    
    # This function returns an array of all valid neighbors
    # of a given map point. This neighbors are considered to be
    # successors/children when searching for the path.
    def getNeighbors(nPoint)
        # Initialize neighbors array
        neighbors = []
        
        # Check near points
        # The sequence of the 'search' doesn't really matter
        n = XYLoc.new(nPoint.x + 1, nPoint.y)
        if (n.x < @width && self.getMapValue(n.x, n.y) == 1)
            neighbors.push(n)
        end
        
        n = XYLoc.new(nPoint.x - 1, nPoint.y)
        if (n.x >= 0 && self.getMapValue(n.x, n.y) == 1)
            neighbors.push(n)
        end
        
        n = XYLoc.new(nPoint.x, nPoint.y + 1)
        if (n.y < @height && self.getMapValue(n.x, n.y) == 1)
            neighbors.push(n)
        end
        
        n = XYLoc.new(nPoint.x, nPoint.y - 1)
        if (n.y >= 0 && self.getMapValue(n.x, n.y) == 1)
            neighbors.push(n)
        end
        
        # Return neighbors
        return neighbors
            
    end
    
    # This is the search function
    # Searhes for a path using a simple search by width (checking all
    # children first).
    # This algorithm uses a new array (visited) that keeps the index of
    # visiting a point by setting the paretn's index + 1. This way we know
    # that all the points with visited index 2 are children of the point
    # with visited index 1. It is also the number of moves from the start point.
    #
    # When the search is done, we extract the path.
    def findPath(startPoint, endPoint)
        # Initialize node array
        # This array will host all the map points we are going to visit
        # On each visit the point will be removed and marked as visited
        q = []
        # This is tie visited array that keeps the visit index
        @visited = Array.new(@width * @height, 0)
        
        # Add first point to visited
        @visited[self.getXYIndex(startPoint)] = 1
        
        # Add current point (the start point) to the search pool
        currentPoint = XYLoc.new(startPoint.x, startPoint.y)
        q.push(currentPoint)

        # Search until all points are searched
        while (q.count() > 0)
            # Get first item (and remove from the pool)
            pnext = q.shift
            
            # Get neighbors/children
            succList = self.getNeighbors(pnext)
            for succ in succList
                # Check if point already visited
                if (@visited[self.getXYIndex(succ)] >= 1)
                    next
                end
                # Set visited index as the current visited index + 1
                @visited[self.getXYIndex(succ)] = @visited[self.getXYIndex(pnext)] + 1
                
                # Check if the end point is found
                if (succ.x == endPoint.x && succ.y == endPoint.y)
                    # Extract path
                    return self.extractPath(endPoint)
                end
                
                # Point is not the goal point.
                # Push the point into the search pool.
                q.push(succ)
            end
        end
        
        # The search pool is empty and the goal point hasn't
        # been reached. Return empty path.
        return []
    end
    
    # Given the visited array, this function extracts the path starting
    # from the end point and go back searching for the parent each time
    # until the parent is 1. The path is reversed before returing.
    def extractPath(goalPoint)
        # Set initial cost
        currCost = @visited[self.getXYIndex(goalPoint)];
        
        # Initialize final path and add the goal point
        finalPath = []
        finalPath.push(goalPoint)

        # Search until the cost reaches to 1 (start point)
        while (currCost > 1)
            # Get reverse neighbors
            succList = self.getNeighbors(finalPath[-1])
            for succ in succList
                # Check if it is the previous because the cost is -1
                if (@visited[self.getXYIndex(succ)] == currCost-1)
                    finalPath.push(succ)
                    currCost -= 1
                    break
                end
            end
        end
        
        # Reverse path and return it
        return finalPath.reverse
    end
    
    # Draw the map
    def drawMap
        print "Width: "+@width.to_s+"\n"
        print "Height: "+@height.to_s+"\n"
        print @mapTextContent+"\n"
    end
    
    # Draw the map including start, end points and the path
    def drawMapPath(startPoint, endPoint, path)
        print "Width: "+@width.to_s+"\n"
        print "Height: "+@height.to_s+"\n"
        print "Path Length: "+path.count.to_s+"\n"
        print self.getMapToText(startPoint, endPoint, path)+"\n"
    end
    
    # Return a text representation of the map
    # including start, end points and the path
    def getMapToText(startPoint, endPoint, path)
        # Create copy of map
        mapClone = @mapArray
        
        # Add path to the map
        for p in path
            mapClone[self.getXYIndex(p)] = 2
        end
        
        # Start start and end points
        mapClone[self.getXYIndex(startPoint)] = 3
        mapClone[self.getXYIndex(endPoint)] = 3
        
        # Create the text map using different values
        # for the wall, spaces, start and goal points
        # and the path.
        mapText = ""
        for y in 0..@height-1
            for x in 0..@width-1
                index = self.getMapIndex(x, y)
                if (mapClone[index] == 0)
                    mapText += "@"
                elsif (mapClone[index] == 1)
                    mapText += "."
                elsif (mapClone[index] == 2)
                    mapText += "*"
                elsif (mapClone[index] == 3)
                    mapText += "#"
                else
                    mapText += "."
                end
            end
            mapText += "\n"
        end
        
        # Return the map
        return mapText
    end
end

# Class: XYLoc
#
# This class represents a 2-dimensions point in the map.
# It has x and y values for coordinates
class XYLoc
    # Initialize the point
    def initialize(x, y)
        # Set point position
        @x = x
        @y = y
    end
    
    # Get/Set x
    def x
        @x
    end
    
    # Get/Set y
    def y
        @y
    end
end