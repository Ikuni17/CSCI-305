'''
Bradley White
CSCI 305: Lab 2, MT Highway Graph
March 16, 2016

Developed with Python 3.5.1 and requires city1.txt to be in the same directory.
This solution uses vertex and graph objects to manipulate the data. Then Breadth
First Search is used to find paths.
'''

# Libraries used
import re
import sys
import queue

# Vertex object for each city in the graph
class Vertex:
    def __init__(self, city):
        self.id = city
        # Store the connected vertices as the keys in a dictionary with the miles as the value
        self.connections = {}
        # Path list between two cities, used with BFS
        self.path = []
        # Mileage between two cities, used with BFS
        self.miles = 0
        # Amount of hops between two cities, used with BFS, initially "infinity"
        self.distance = sys.maxsize

    # Add a new edge between vertices to the dictionary
    def add_connection(self, neighbor, weight = 0):
        self.connections[neighbor] = weight
    
    # Return the vertices connected to this one
    def get_connections(self):
        return self.connections.keys()
    
    # Return the city represented by this object
    def get_id(self):
        return self.id
    
    def set_distance(self, dist):
        self.distance = dist
        
    def get_distance(self):
        return self.distance
    
    def get_miles(self):
        return self.miles
    
    def set_miles(self, m):
        self.miles = m
    
    # Append a new city on the path between two cities
    def add_path(self, node):
        self.path = self.path + [node]
        
    def get_path(self):
        return self.path
    
    # Required to copy a parent's path or else lists become nested
    def set_path(self, node):
        self.path = node

    # Make the path empty before starting a new BFS
    def reset_path(self):
        self.path = []

# Graph object
class Graph:
    def __init__(self):
        # Dictionary of all vertices with the city as the key and it's corresponding vertex object as the value
        self.vertices = {}
    
    # Add a new vertex to the graph
    def add_vertex(self, node):
        new_vertex = Vertex(node)
        self.vertices[node] = new_vertex
    
    # Add a new edge between two cities
    def add_edge(self, city1, city2, miles = 0):
        # Check that the cities have vertices, if not create them
        if city1 not in self.vertices:
            self.add_vertex(city1)
        if city2 not in self.vertices:
            self.add_vertex(city2)
        
        # Populate the connections dictionary for each vertex with the milage of the edge between them
        # Since the graph is undirected, connections are made for both cities
        self.vertices[city1].add_connection(self.vertices[city2], miles)
        self.vertices[city2].add_connection(self.vertices[city1], miles)

# Create a new graph   
graph = Graph()
# Read the input file into a list, where each line from the file is a string
file = open("city1.txt", "r")
cityList = file.readlines()
file.close()

# Tokenize each string into a sublist and remove whitespace larger than two
# Will be in the form [['From', 'To', 'Miles'],[...]]
for i in range (0, len(cityList)):
    cityList[i] = cityList[i].splitlines()
    cityList[i] = re.split("  +", cityList[i][0])

# Start the loop after the irrelevant information from the start of the file
for i in range(5, len(cityList)):
    # Skip sublists with only one entry because they are only hyphens
    if(len(cityList[i]) != 1):
        # Add edges to the graph for each sublist. add_edge will create vertices as needed
        graph.add_edge(cityList[i][0], cityList[i][1], int(cityList[i][2]))

# Check for a direct connection between two query cities
def direct_connection(city1, city2):
    check = False
    
    # Check that both cities are in the graph first
    if city1 in graph.vertices and city2 in graph.vertices:
        # Iterate through all the connections of the first query city
        for i in graph.vertices[city1].get_connections():
            if(i.get_id() == city2):
                check = True
    return check

# Uses the BFS algorithm which needs the queue library
def breadth_first_search(city1, city2):
    # Create a new queue and re-initialize the graph with helper function
    q = queue.Queue()
    reset_graph()
    
    # Set the first city to 0 hops and a path to itself, then put it's vertex in the queue
    graph.vertices[city1].set_distance(0)
    graph.vertices[city1].add_path(graph.vertices[city1].get_id())
    q.put(graph.vertices[city1])
    
    # Loop until all possible vertices have been checked
    while q.empty() == False:       
        # Remove the first vertex from the queue
        current = q.get()
        
        # Iterate through all connected vertices for each vertex
        for i in current.get_connections():
            # Check if distance is infinity, if not go to the next connection
            if(i.get_distance() == sys.maxsize):
                # Set the connection's distance to the parent's distance plus one
                i.set_distance(current.get_distance() + 1)
                # Set the connection's mileage to the parent's plus the edge in between them
                i.set_miles(current.connections[i] + current.get_miles())
                # Set the connection's path to the parent's path
                i.set_path(current.get_path())
                # Add itself to the path
                i.add_path(i.get_id())
                # Put the connection into the queue
                q.put(i)

# Iterate through each vertex and it's connections and reset distance to "infinity",
# miles to 0 and the path to an empty list
def reset_graph():
    for i in graph.vertices:
        graph.vertices[i].set_distance(sys.maxsize)
        graph.vertices[i].set_miles(0)
        graph.vertices[i].reset_path()
        
        for j in graph.vertices[i].get_connections():
            j.set_distance(sys.maxsize)
            j.set_miles(0)
            j.reset_path()

# Starts the program and handles user input
def get_input():
    print("CSCI Lab 2 submitted by Bradley White using Python 3.5.1")
    print()
    print("Available functions:")
    print()
    print("1. Find number of cities directly connected to query city")
    print("2. Find if there is a direct connection between two query cities")
    print("3. Find a k-hop path between two query cities and display the path and distance")
    print("4. Find any path between two query cities and display the path and distance")
    
    # Request user input until they choose to quit
    while True:
        print()
        choice = input("Please enter 1-4 corresponding to a function or q to quit: ")

        # Find number of cities directly connected to query city
        if(choice == "1"):
            # Request and store user input
            city = input("Please enter a query city: ")
            print()
            
            # Check that the vertex is in the graph
            if(city in graph.vertices):
                # Prints the size of the connections dictionary
                print("Number of connections to", city, ":", len(graph.vertices[city].connections))
            else:
                print(city, "is not in the graph.")
        
        # Find if there is a direct connection between two query cities
        elif(choice == "2"):
            # Request and store user input
            city1 = input("Please enter the first city: ")
            city2 = input("Please enter the second city: ")
            print()
            
            # Check that both vertices are in the graph
            if city1 in graph.vertices and city2 in graph.vertices:
                # Call helper function
                check = direct_connection(city1, city2)
                # Print the results
                if check is False:
                    print("No there is not a direct connection between", city1, "and", city2)
                else:
                    print("Yes there is a direct connection between", city1, "and", city2)
            else:
                print("One of the cities is not in the graph")
        
        # Find a k-hop path between two query cities and display the path and distance
        elif(choice == "3"):
            # Request and store user input
            city1 = input("Please enter the first city: ")
            city2 = input("Please enter the second city: ")
            hops = int(input("Please enter the maximum number of hops between the two cities: "))
            print()
            
            # Check that both vertices are in the graph
            if city1 in graph.vertices and city2 in graph.vertices:
                # Call helper function
                breadth_first_search(city1, city2)
                # If a path was found that is less than or equal to the amount of hops print the results
                if(graph.vertices[city2].get_distance() <= hops):
                    print("Yes, there is a path that meets the criteria")
                    print("The total distance is:", graph.vertices[city2].get_miles(), "miles")
                    # Formatting to print the path comma seperated on the same line
                    print("The path is:", end = " ")
                    path = graph.vertices[city2].get_path()
                    for i in range(0, len(path)):
                        if(i != (len(path)-1)):
                            print(path[i], end = ", ")
                        else:
                            print(path[i], end ="")
                    print()
                else:
                    print("No, there is not a path that meets the criteria")
            else:
                print("One of the cities is not in the graph")
        
        # Find any path between two query cities and display the path and distance
        elif(choice == "4"):
            # Request and store user input
            city1 = input("Please enter the first city: ")
            city2 = input("Please enter the second city: ")
            print()
            
            # Check that both vertices are in the graph
            if city1 in graph.vertices and city2 in graph.vertices:
                # Call helper function
                breadth_first_search(city1, city2)
                # If the second city's distance is not "infinity" a path was found to it
                if(graph.vertices[city2].get_distance() != sys.maxsize):
                    print("Yes, there is a path between", city1, "and", city2)
                    print("The total distance is:", graph.vertices[city2].get_miles(), "miles")
                    print("The path is:", end = " ")
                    # Formatting to print the path comma seperated on the same line
                    path = graph.vertices[city2].get_path()
                    for i in range(0, len(path)):
                        if(i != (len(path)-1)):
                            print(path[i], end = ", ")
                        else:
                            print(path[i], end ="")
                    print()
                else:
                    print("No, there is not a path between", city1, "and", city2)
            else:
                print("One of the cities is not in the graph")
            
        elif(choice == "q"):
            break
        
        else:
            print("Please enter a valid choice")

# Start!            
get_input()