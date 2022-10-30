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
   void bake(Map map)
   {
     
     ArrayList<Integer> reflexAngles = new ArrayList<Integer>();
     System.out.println(map.walls.size());
     
      for(int i = 0; i < map.walls.size() - 1; i++) { //<>//
          float direction = map.walls.get(i).normal.dot(map.walls.get(i+1).direction);
          System.out.println(direction);
          if(direction >0) {
            reflexAngles.add(i); 
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
   }
}
