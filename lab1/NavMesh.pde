// Useful to sort lists by a custom key
import java.util.Comparator;


/// In this file you will implement your navmesh and pathfinding. 

/// This node representation is just a suggestion
class Node
{
   int id;
   ArrayList<Wall> polygon;
   PVector center;
   ArrayList<Node> neighbors;
   ArrayList<Wall> connections;
}



class NavMesh
{   
   ArrayList<Integer> reflexAngles;
   ArrayList<Wall> navMeshWalls; 
   void bake(Map map)
   {
     reflexAngles  = new ArrayList<Integer>();
     navMeshWalls = new ArrayList<Wall>();
     
     for(int i = 0; i < map.walls.size()-1; i++)  //<>//
     { //we do not need to check the last edge as it is the bottom left corner
       float direction = map.walls.get(i).normal.dot(map.walls.get(i+1).direction); //get dot product of the current edge normal to the next edge
       
       if(direction > 0) { //if the dot product is positive, then the angle between the edges is reflex
         reflexAngles.add(i); 
         
         float maxDistance = 0;
         int targetEdge = 0;
         for(int j = 0; j < map.walls.size(); j++) 
         {
           if(j != (i) && j!= (i + 2)) //do not check neighboring vertices
           {
             float deltaX =  map.walls.get(j).start.x - map.walls.get(i).end.x;
             float deltaY =  map.walls.get(j).start.y - map.walls.get(i).end.y;
             double distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY)); //calculate distance between current vertex and other vertices
             
             Wall testWall = new Wall(map.walls.get(i).end, map.walls.get(j).start);
             PVector testStart = PVector.add(testWall.start, PVector.mult(testWall.direction, 0.05));
             PVector testEnd = PVector.add(testWall.end, PVector.mult(testWall.direction, -0.05));
             testWall = new Wall(testStart, testEnd);
             
             if(distance > maxDistance && map.collides(testWall.start, testWall.end)==false && isPointInPolygon(testWall.center(), map.walls) == true) 
             {
               maxDistance = (float)distance;
               targetEdge = j; //set target vertex as the furthest one without crossing the walls
             }
           }
         }
         
         navMeshWalls.add(new Wall(map.walls.get(i).end, map.walls.get(targetEdge).start));
        }
      }
    
   }
   
   ArrayList<PVector> findPath(PVector start, PVector destination)
   {
      /// implement A* to find a path
      ArrayList<PVector> result = null;
      return result;
   }
   
   
   void update(float dt)
   {
      draw();
   }
   
   void draw()
   {
      /// use this to draw the nav mesh graph
      for(int i = 0; i < navMeshWalls.size(); i++) {
        stroke(#eb4034);
        line(navMeshWalls.get(i).start.x, navMeshWalls.get(i).start.y, navMeshWalls.get(i).end.x, navMeshWalls.get(i).end.y);
        //stroke(#eb4034);
      }
   }
}
