// Useful to sort lists by a custom key
import java.util.Comparator;
import java.util.*;


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
   ArrayList<ArrayList<Wall>> graph;
   
   //calculate the NavMesh using EarTrimming method
   void bake(Map map)
   {
     Map mapCopy = map;
     reflexAngles  = new ArrayList<Integer>();
     navMeshWalls = new ArrayList<Wall>(); //<>//
     graph = new ArrayList<ArrayList<Wall>>();
     ArrayList<PVector> nodes = new ArrayList<PVector>(); //<>//
    
      /**
      for (int i = 0; i < mapCopy.walls.size(); i++)
      {
        nodes.add(mapCopy.walls.get(i).start);
        map.walls.get(i).index = i;
      }
      */
      
      for(Wall w : mapCopy.walls) 
      {
        nodes.add(w.start);
      }
      System.out.println("before: " + nodes.size());
      earTrimming(nodes); 
      System.out.println("done");
   }
   
   boolean earTrimming(ArrayList<PVector> nodes) 
   {
     if(nodes.size() == 3)
     {
       return true;
     }
       
     ArrayList reflexVerts = new ArrayList<Integer>();
     Map currentMap = new Map();
     
     PVector[] n = new PVector[nodes.size()];
     for(int j = 0; j < nodes.size(); j++){
       n[j] = nodes.get(j);
     }
     
     AddPolygon(currentMap.walls , n);
     reflexVerts = recalculateReflex(currentMap, reflexVerts);
     
     for(int k = 0; k <  reflexVerts.size(); k++)
     {
       //System.out.println(reflexVerts.get(k));
     }
     
     
     //we are assuming that the map given is sufficient for earTrimming
     //verts.length == 3 when there is only one triangle remaining in the map
     
       for(int i = 0;  i < currentMap.walls.size(); i++)
       {
         
         if(!reflexVerts.contains(currentMap.walls.get(i)))
         {
           //System.out.println(i);
           ArrayList<Wall> polygon = new ArrayList<Wall>();
           polygon.add(getNeighbour(currentMap.walls, i-1));
           polygon.add(getNeighbour(currentMap.walls, i));
           polygon.add(new Wall(getNeighbour(currentMap.walls, i-1).start, getNeighbour(currentMap.walls, i+1).start)); //<>//
           
           
           //navMeshWalls.add(new Wall(getNeighbour(copyMap.walls, i-1).start, getNeighbour(copyMap.walls, i+1).start));
           
           //System.out.println(nodes.size());
           if(validEar(polygon, n, (i-1), i, (i+1))) //<>//
           {
             System.out.println("Making ear using: " + (i-1) + "  " + i + " " + (i+1));
             //remove the vertex as it has been remove with the ear
             
             nodes.remove(i);
             graph.add(polygon); //<>//
             break; //<>//
           }
         }
       }
      
     return earTrimming(nodes);
   }
   
   
   Wall getNeighbour(ArrayList<Wall> walls, int index) {
     if(index >= walls.size())
       index = index % walls.size();
     else if(index < 0)
       index = index % walls.size() + walls.size();
     
     return walls.get(index);
   }
   
   int loopIndex(ArrayList<Wall> walls, int ind)
   {
     if(ind >= walls.size())
       ind = ind % walls.size();
     else if(ind< 0)
       ind = ind % walls.size() + walls.size();
      return ind;
   }
   
   ArrayList recalculateReflex(Map tempMap, ArrayList<Integer> reflexVerts) 
   {
     reflexVerts.clear();
     for(int i = 0; i < tempMap.walls.size(); i++) 
     {
       float direction = tempMap.walls.get(i).normal.dot(getNeighbour(tempMap.walls, i+1).direction); //get dot product of the current edge normal to the next edge
      
       if(direction > 0) 
       { //if the dot product is positive, then the angle between the edges is reflex
         reflexVerts.add(i); 
        
       }
       
       for(int k = 0; k < reflexVerts.size(); k++)
       {
         System.out.print(" " + reflexVerts.get(k));
       }
       
     }
     
     return reflexVerts;
   }
   
   
   boolean validEar(ArrayList<Wall> polygon, PVector[] n, int a, int b, int c)
   {
     boolean valid = true;
     System.out.println(n.length);
     for(int i = 0; i < n.length; i++)
     {
       if(i == a)
         continue;
       if(i == b)
         continue;
       if(i == c)
         continue;
       if(isPointInPolygon(n[i], polygon))
         valid = false;
             
     }
     if(valid == false)
       System.out.println("doesnt work");
     
     return valid;
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
     
      
      for(int i = 0; i < graph.size(); i++) 
      {
        for(int j = 0; j < graph.get(i).size(); j++)
        {
          stroke(#eb4034);
          line(graph.get(i).get(j).start.x, graph.get(i).get(j).start.y, graph.get(i).get(j).end.x, graph.get(i).get(j).end.y);
          
        }
      }     
   }
}
