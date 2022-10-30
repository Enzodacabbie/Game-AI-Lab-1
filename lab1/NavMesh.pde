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
   ArrayList<Integer> reflexAngles = new ArrayList<Integer>();
   ArrayList<Wall> navMeshWalls = new ArrayList<Wall>();
   void bake(Map map)
   {
     
      for(int i = 0; i < map.walls.size() - 1; i++) { //<>//
          float direction = map.walls.get(i).normal.dot(map.walls.get(i+1).direction);
          System.out.println(direction);
          
          if(direction > 0) { //if the dot product is positive, then the angle between the edges is reflex
            reflexAngles.add(i); 
            navMeshWalls.add(new Wall(map.walls.get(i).end, map.walls.get(i-1).start));
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
        line(navMeshWalls.get(i).start.x, navMeshWalls.get(i).start.y, navMeshWalls.get(i).end.x, navMeshWalls.get(i).end.y);
      }
   }
}
