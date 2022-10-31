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
     
     for(int i = 0; i < map.walls.size() - 1; i++)  //<>//
     { //we do not need to check the last edge as it is the bottom left corner
       float direction = map.walls.get(i).normal.dot(map.walls.get(i+1).direction); //get dot product of the current edge normal to the next edge
       
       if(direction > 0) 
       { //if the dot product is positive, then the angle between the edges is reflex
         reflexAngles.add(i); 
       }
        //<>//
      }
      earTrimming(mapCopy, reflexAngles); 
      System.out.println("done");
   }
   
   void earTrimming(Map copyMap, ArrayList<Integer> reflexVerts) 
   {
     ArrayList verts = new ArrayList<Integer>();
     
     //populate the list of vertices with the number of walls in the map
     for(int i = 0;  i < copyMap.walls.size(); i++)
     {
       verts.add(i);
     }
     
     int numberOfTriangles = verts.size() - 2;
     
     //we are assuming that the map given is sufficient for earTrimming
     //verts.length == 3 when there is only one triangle remaining in the map
     while(verts.size() > 3) //<>//
     {
       for(int i = 0;  i < verts.size(); i++)
       {
         if(!reflexVerts.contains(verts.get(i)))
         {
           ArrayList<Wall> polygon = new ArrayList<Wall>();
           polygon.add(getNeighbour(copyMap.walls, i-1));
           polygon.add(getNeighbour(copyMap.walls, i));
           polygon.add(new Wall(getNeighbour(copyMap.walls, i-1).start, getNeighbour(copyMap.walls, i+1).start));
           
           
           //navMeshWalls.add(new Wall(getNeighbour(copyMap.walls, i-1).start, getNeighbour(copyMap.walls, i+1).start));
           
           if(validEar(polygon, map))
           {
             //remove the vertex as it has been remove with the ear
             verts.remove(i);
             graph.add(polygon);
             
             //add new wall from the start of the previous neighbour to the start of the next neighbour
             //copyMap.walls.remove(loopIndex(copyMap.walls, i-1));
             //copyMap.walls.add(loopIndex(copyMap.walls, i-1), new Wall(getNeighbour(copyMap.walls, i-1).start, getNeighbour(copyMap.walls, i+1).start));
             //copyMap.walls.remove(loopIndex(copyMap.walls, i));
             
             reflexVerts = recalculateReflex(copyMap, reflexVerts);
           }
         }
       }
       
     }
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
       
     }
     return reflexVerts;
   }
   
   
   boolean validEar(ArrayList<Wall> polygon, Map map)
   {
     boolean valid = true;
     
     for(int i = 0; i < map.walls.size(); i++)
     {
       if(isPointInPolygon(map.walls.get(i).end, polygon))
         valid = true;
     }
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
     
      System.out.println(graph.size());
      for(int i = 0; i < graph.size(); i++) 
      {
        for(int j = 0; j < graph.get(i).size(); j++)
        {
          line(graph.get(i).get(j).start.x, graph.get(i).get(j).start.y, graph.get(i).get(j).end.x, graph.get(i).get(j).end.y);
          stroke(#eb4034);
        }
      }     
   }
}
