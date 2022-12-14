// Useful to sort lists by a custom key
import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.Collections;

/// In this file you will implement your navmesh and pathfinding. 

/// This node representation is just a suggestion
class Node
{
   int id;
   ArrayList<Wall> polygon;
   PVector center;
   ArrayList<Node> neighbors;
   ArrayList<Wall> connections;
   ArrayList<PVector> vertices;
   
   Node previousNode;
   float distanceTraveled;
   double heuristic;
   double totalCost;
   
   //constructor, takes in the walls that make up polygon and ID
   Node(ArrayList<Wall> walls, int ID) 
   {
     id = ID;
     polygon = walls;
     vertices = findVertices();
     center = getCenter();
     neighbors = new ArrayList<Node>();
     connections = new ArrayList<Wall>();
   }
   
   //default constructor
   Node() 
   {
     neighbors = new ArrayList<Node>();
     connections = new ArrayList<Wall>();
   }
   
   //creates a new wall between the center of this node and some PVector, preferably the center of another node
   void createNewConnection(PVector target)
   {
     connections.add(new Wall(center, target));
   }
   
   
   //calculate the center by taking the mean of the vertices
   PVector getCenter() 
   {
     PVector cent = new PVector(0,0); 
     
     for(PVector v: vertices)
     {
       cent.add(v);
     }
     return cent.div(3);
   }
   
   //returns an arrayList of PVectors which are the vertices
   ArrayList<PVector> findVertices()
   {
     ArrayList<PVector> verts = new ArrayList<PVector>();
     //go through the polygon and add the start/end of each wall
     for(int i = 0; i < polygon.size(); i++) 
     {
       //this check is made as if a wall is not facing the correct way, a vertex could be double counted
       if(!verts.contains(new PVector(polygon.get(i).start.x, polygon.get(i).start.y)))
       {
         verts.add(new PVector(polygon.get(i).start.x, polygon.get(i).start.y));
       }
       else 
       {
         verts.add(new PVector(polygon.get(i).end.x, polygon.get(i).end.y));
       }
       
     }
     return verts;
   }
   
   //adds node to list of neighbors and adds a wall between the centers
   void addNeighbour(Node n, PVector otherCenter) 
   {
     connections.add(new Wall(center, otherCenter));
     neighbors.add(n);
   }
   
   //calculates the straight line distance from the center to a target
   void setHeuristic(PVector target)
   { 
     double x = target.x - center.x;
     double y = target.y - center.y;
     double distance = Math.sqrt(x*x + y*y);
     heuristic = distance;
   }
   
   //calculate the distance between the center of this node and an input node
   //then, add that distance to overall distance traveled by the input node
   //input node is meant to be previous node
   void setCost(Node n)
   {
    PVector origin = n.center;
    double x = center.x - origin.x;
    double y = center.y - origin.y;
    double distance = Math.sqrt(x*x + y*y);
    totalCost = distance + n.distanceTraveled;
   }
   
   //return cost
   double getTotalCost()
   {
     return totalCost;
   }
   
   //set the previous node to node
   void setPrevious(Node n)
   {
     previousNode = n;
   }
}

class NavMesh
{  //holds the index of walls that contain reflex angles
   ArrayList<Integer> reflexAngles;
  
   //holds newly created walls in NavMesh
   ArrayList<Wall> navMeshWalls; 
   
   //holds a collection of ArrayLists which correspond to all polygons within NavMesh
   ArrayList<ArrayList<Wall>> graph;
   
   //holds collections of Nodes of the NavMesh
   ArrayList<Node> graphNodes;
   
   //calculate the NavMesh using EarTrimming method
   void bake(Map map)
   {
     //make a copy of the map as to not to change structure of level
     Map mapCopy = map;
     
     //holds the indices of the walls that contain reflex angles
     reflexAngles  = new ArrayList<Integer>();
     
     //holds the set of new Walls that are created during the creation of NavMesh
     navMeshWalls = new ArrayList<Wall>();
     
     //holds the polygons that make up the navmesh
     graph = new ArrayList<ArrayList<Wall>>();
     
     //holds the nodes that make up the navmesh graph
     ArrayList<PVector> nodes = new ArrayList<PVector>();
     
     graphNodes = new ArrayList<Node>();
      
     //copy the vertices into an arrayList of vertices
     for(Wall w : mapCopy.walls) 
     {
       nodes.add(w.start);
     }
     
     //decompose the polygon into a set of triangles
     earTrimming(nodes, 0); 
     
     //create Nodes out of the newly formed triangles
     createNodes(graph);
     
   }
   
   //method that uses triangulation via Ear Trimming to decompose polygon
   //recursively calls until there are only three vertices remaining in list of vertices
   boolean earTrimming(ArrayList<PVector> nodes, int iteration) 
   {
     ArrayList reflexVerts = new ArrayList<Integer>();
     Map currentMap = new Map();
     
     //copy arrayList of vertices into static array
     //this will be used to create new polygon based on the vertices
     PVector[] n = new PVector[nodes.size()];
     for(int j = 0; j < nodes.size(); j++){
       n[j] = nodes.get(j);
     }
     
     //if nodes == 3, we are at the last triangle
     //store the triangle and return
     if(nodes.size() == 3)
     {
       ArrayList<Wall> polygon = new ArrayList<Wall>();
       AddPolygon(polygon, n);
       graph.add(polygon);
       return true; 
     }
     
     //create map based off of the vertices given
     AddPolygon(currentMap.walls , n);
     
     //calculate the reflex vertices of the generated map
     recalculateReflex(currentMap, reflexVerts, iteration);
     
     //go through all of the vertices
     //if vertex is not reflex, create a triangle with the edges from i-1 and i+1 and the conncection of i-1 and i+1
     //if none of the other vertices lie inside this new triangle,
     //add this triangle to navmesh graph and remove the vertex used to create the triangle
     //recursively call this method with the vertices minus the one removed
     for(int i = 0;  i < currentMap.walls.size(); i++)
       {
         //if the current vertex is not reflex
         if(!reflexVerts.contains(i))
         {
           //create new triangle (ear) to check
           ArrayList<Wall> polygon = new ArrayList<Wall>();
           polygon.add(getNeighbour(currentMap.walls, i-1));
           polygon.add(getNeighbour(currentMap.walls, i));
           polygon.add(new Wall(getNeighbour(currentMap.walls, i-1).start, getNeighbour(currentMap.walls, i+1).start));
          
           //if none of the other vertices lie within this triangle
           //add the triangle to the navmesh and remove the vertex used
           if(validEar(polygon, n, (i-1), i, (i+1)))
           {
             //System.out.println("Making ear using: " + (i-1) + "  " + i + " " + (i+1));
             
             //arraylist will store the new set of vertices minus the vertex removed
             //it will be used as input into the recursive call
             ArrayList<PVector> nds = new ArrayList<PVector>();
             
             //remove the index from the array of nodes that make up the map
             for(int k = 0; k < nodes.size() ; k++) 
             {
               if(k != i) 
               {
                 //add all nodes that are not the node that was removed
                 nds.add(nodes.get(getIndex(currentMap.walls, k )));
               }
             }
             nodes = nds;
             graph.add(polygon);
             break;
           }
         }
       }
      
     //recursively call the function by
     //reducing the number of nodes by one each time
     //until we are left with three nodes remaining
     //iteration is incremented as the way for calculating reflex vertices is different 
     //only for the very first iteration
     return earTrimming(nodes, ++iteration);   
   } //<>//
   
  //returns the wall of parameter index
  //indices are looped to create a looped Array
   Wall getNeighbour(ArrayList<Wall> walls, int index) {
     if(index >= walls.size())
       index = index % walls.size();
     else if(index < 0)
       index = index % walls.size() + walls.size();
     
     return walls.get(index);
   }
   
   //returns the looped Index for an arrayList 
   int getIndex(ArrayList<Wall> walls, int index) 
   {
     if(index >= walls.size())
       index = index % walls.size();
     else if(index < 0)
       index = index % walls.size() + walls.size();
     
     return index;
   }
   
   //goes through a Map and calculates which vertices are reflex
   ArrayList recalculateReflex(Map tempMap, ArrayList<Integer> reflexVerts, int iteration) 
   {
     reflexVerts.clear();

     for(int i = 0; i < tempMap.walls.size(); i++) 
     {
       float direction;
       
       //the reflex vertices are calculated differently only on the first time as removing vertices messes with the order 
       if(iteration == 0) 
       {
         direction = tempMap.walls.get(i).normal.dot(getNeighbour(tempMap.walls, i+1).direction);
       }
       else
       {
         direction = getNeighbour(tempMap.walls, i-1).normal.dot(tempMap.walls.get(i).direction); //get dot product of the current edge normal to the next edge
       }
        
       if(direction > 0) 
       { //if the dot product is positive, then the angle between the edges is reflex
         reflexVerts.add(i); 
       }
     }
     return reflexVerts;
   }
   
   //checks if any elements of a set of PVectors lays inside a given polygon
   boolean validEar(ArrayList<Wall> polygon, PVector[] n, int a, int b, int c)
   {
     boolean valid = true;
     for(int i = 0; i < n.length; i++)
     {
       //skip the points that make up the ear being checked
       if(i == a)
         continue;
       if(i == b)
         continue;
       if(i == c)
         continue;
         
       //if a single point is inside the polygon, then the ear is not valid
       if(isPointInPolygon(n[i], polygon))
         valid = false; 
     }
     
     return valid;
   }
   
   //creates nodes for NavMesh from arrayList of polygons generated in ear trimming
   void createNodes(ArrayList<ArrayList<Wall>> triangles) 
   { //<>//
     for(int i = 0; i < triangles.size(); i++)
     {
       Node node = new Node(triangles.get(i), i);
       graphNodes.add(node);
     }
     
     
     //go through each node, then check every other node if they share any vertices
     for(int k = 0; k < triangles.size(); k++)
     { 
       for(int j = 0; j < graphNodes.size(); j++)
       {   //<>//
         int counter = 0;
         if(((graphNodes.get(k).vertices.get(0).x == graphNodes.get(j).vertices.get(0).x) && (graphNodes.get(k).vertices.get(0).y == graphNodes.get(j).vertices.get(0).y)) || 
         ((graphNodes.get(k).vertices.get(0).x == graphNodes.get(j).vertices.get(1).x) && (graphNodes.get(k).vertices.get(0).y == graphNodes.get(j).vertices.get(1).y)) || 
         ((graphNodes.get(k).vertices.get(0).x == graphNodes.get(j).vertices.get(2).x) && (graphNodes.get(k).vertices.get(0).y == graphNodes.get(j).vertices.get(2).y))) 
         {
           counter = counter +1;
         }
         
         if(((graphNodes.get(k).vertices.get(1).x == graphNodes.get(j).vertices.get(0).x) && (graphNodes.get(k).vertices.get(1).y == graphNodes.get(j).vertices.get(0).y)) || 
         ((graphNodes.get(k).vertices.get(1).x == graphNodes.get(j).vertices.get(1).x) && (graphNodes.get(k).vertices.get(1).y == graphNodes.get(j).vertices.get(1).y)) || 
         ((graphNodes.get(k).vertices.get(1).x == graphNodes.get(j).vertices.get(2).x) && (graphNodes.get(k).vertices.get(1).y == graphNodes.get(j).vertices.get(2).y))) 
         {
           counter = counter +1;
         }
         
          if(((graphNodes.get(k).vertices.get(2).x == graphNodes.get(j).vertices.get(0).x) && (graphNodes.get(k).vertices.get(2).y == graphNodes.get(j).vertices.get(0).y)) || 
         ((graphNodes.get(k).vertices.get(2).x == graphNodes.get(j).vertices.get(1).x) && (graphNodes.get(k).vertices.get(2).y == graphNodes.get(j).vertices.get(1).y)) || 
         ((graphNodes.get(k).vertices.get(2).x == graphNodes.get(j).vertices.get(2).x) && (graphNodes.get(k).vertices.get(2).y == graphNodes.get(j).vertices.get(2).y))) 
         {
           counter = counter +1;
         }
         
         //if they share 2 vertices, that means that they share an edge and are neighbors
         //as every polygon is a triangle, only need to check if 2 vertices match
         if(counter == 2)
         {
           graphNodes.get(k).addNeighbour(graphNodes.get(j), graphNodes.get(j).center);
         }
       }
     }
   }
   
   //finds path from start PVector to destination PVector using A* search
   ArrayList<PVector> findPath(PVector start, PVector destination)
   {
     //priority queue which stores the search frontier, sorts by the total cost of the nodes
     PriorityQueue<Node> frontier = new PriorityQueue<>(Comparator.comparing(Node::getTotalCost));
     
     //holds the nodes that have already been visited
     ArrayList<Integer> visitedNodes = new ArrayList<Integer>();
     
     ArrayList<PVector> result = new ArrayList<PVector>();
      
      //set the heuristic for every node in the graph
      for(int i = 0; i < graphNodes.size(); i++)
      {
        graphNodes.get(i).setHeuristic(destination);
      }
      
      //determine what node we are starting in
      Node startNode = new Node();
      Node endNode = new Node();
      for(int j = 0; j < graphNodes.size(); j++)
      {
        if(isPointInPolygon(start, graphNodes.get(j).polygon) == true)
          startNode = graphNodes.get(j);
        
        if(isPointInPolygon(destination, graphNodes.get(j).polygon) == true)
          endNode =  graphNodes.get(j);
      }
      
      //add the start node to the frontier
      startNode.distanceTraveled = 0;
      frontier.add(startNode);
      
      
      while(frontier.peek().id != endNode.id)
      {
        //remove first node and add to visited
        Node n = frontier.poll();
        visitedNodes.add(n.id);
        //<>//
        for(int i = 0; i < n.neighbors.size(); i++)
        {
          if(!visitedNodes.contains(n.neighbors.get(i).id))
          {
            //add neighbors to frontier if they are not visited
            Node neighbor = n.neighbors.get(i);
            neighbor.setPrevious(n);
            neighbor.setCost(n);
            frontier.add(neighbor);
          }
        }
      }
      //add the final node to the result
      Node path = frontier.poll();
      result.add(destination);
      
      //add the centers of the edge that connects the triangles until we reach starting node
      while(path.id != startNode.id) 
      {
        result.add(findNeighbourWall(path, path.previousNode).center());
        path = path.previousNode;
      }
      
      //add the starting node
      result.add(start);
      
      //reverse the result as we inputted the path backwards
      Collections.reverse(result);
      
      System.out.println("we made it");
      
      return result;
   }
   
   //finds the wall that two nodes share given two nodes
   Wall findNeighbourWall(Node x, Node y)
   {
     PVector vertex1 = null;
     PVector vertex2 = null;
     
     for(int i = 0; i< x.vertices.size(); i++)
     {
       if(x.vertices.get(i).x == y.vertices.get(0).x && x.vertices.get(i).y == y.vertices.get(0).y)
       {
         if(vertex1 == null)
           vertex1 = x.vertices.get(i);
         else
           vertex2 = x.vertices.get(i);
       }
       
       if(x.vertices.get(i).x == y.vertices.get(1).x && x.vertices.get(i).y == y.vertices.get(1).y)
       {
         if(vertex1 == null)
           vertex1 = x.vertices.get(i);
         else
           vertex2 = x.vertices.get(i);
       }
       
       if(x.vertices.get(i).x == y.vertices.get(2).x && x.vertices.get(i).y == y.vertices.get(2).y)
       {
         if(vertex1 == null)
           vertex1 = x.vertices.get(i);
         else
           vertex2 = x.vertices.get(i);
       }
       
     }
     if(vertex1 != null && vertex2 != null)
     {
       return new Wall(vertex1, vertex2);
     }
     return new Wall(new PVector(), new PVector());
   }
   
   
   void update(float dt)
   {
      draw();
   }
   
   void draw()
   {
     //draws the portions of the navmesh
     
     //navmesh walls
      for(int i = 0; i < graph.size(); i++) 
      {
        for(int j = 0; j < graph.get(i).size(); j++)
        {
          stroke(#eb4034);
          line(graph.get(i).get(j).start.x, graph.get(i).get(j).start.y, graph.get(i).get(j).end.x, graph.get(i).get(j).end.y);
          
        }
      }

      //centers
      for(int i =0; i < graphNodes.size(); i++)
      {
        stroke(#ffea00);
          strokeWeight(10);
          line(graphNodes.get(i).center.x,graphNodes.get(i).center.y, graphNodes.get(i).center.x,graphNodes.get(i).center.y);
          
      }

      //vertices
      /**
      for(int i =0; i < graphNodes.size(); i++)
      {

        for(int k = 0; k < graphNodes.get(i).vertices.size(); k++)
        {
          stroke(#0320fc);
          strokeWeight(10);
          
          line(graphNodes.get(i).vertices.get(k).x,graphNodes.get(i).vertices.get(k).y, graphNodes.get(i).vertices.get(k).x,graphNodes.get(i).vertices.get(k).y);
        }
      }
      */
      
      //connection lines
      for(int i =0; i < graphNodes.size(); i++)
      {
        for(int k = 0; k < graphNodes.get(i).connections.size(); k++)
        {
          strokeWeight(1);
          stroke(#ffea00);
          line(graphNodes.get(i).connections.get(k).start.x,graphNodes.get(i).connections.get(k).start.y,graphNodes.get(i).connections.get(k).end.x,graphNodes.get(i).connections.get(k).end.y);
        }
      }
   }
}
