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
   ArrayList<ArrayList<Wall>> graph;
   
   //calculate the NavMesh using EarTrimming method
   void bake(Map map)
   {
     Map mapCopy = map; //<>//
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
      
      earTrimming(nodes, 0); 
      System.out.println("done"); //<>//
   }
   
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
             System.out.println("Making ear using: " + (i-1) + "  " + i + " " + (i+1));
             
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
     return earTrimming(nodes, ++iteration);    //<>// //<>// //<>// //<>// //<>//
   }
   
   
   Wall getNeighbour(ArrayList<Wall> walls, int index) {
     if(index >= walls.size())
       index = index % walls.size();
     else if(index < 0)
       index = index % walls.size() + walls.size();
     
     return walls.get(index);
   }
   
   int getIndex(ArrayList<Wall> walls, int index) 
   {
     if(index >= walls.size())
       index = index % walls.size();
     else if(index < 0)
       index = index % walls.size() + walls.size();
     
     return index;
   }
   
   int loopIndex(ArrayList<Wall> walls, int ind)
   {
     if(ind >= walls.size())
       ind = ind % walls.size();
     else if(ind< 0)
       ind = ind % walls.size() + walls.size();
      return ind;
   }
   
   ArrayList recalculateReflex(Map tempMap, ArrayList<Integer> reflexVerts, int iteration) 
   {
     reflexVerts.clear();

     for(int i = 0; i < tempMap.walls.size(); i++) 
     {
       float direction;
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
     System.out.print("Reflex Vertices: ");
     for(int k = 0; k < reflexVerts.size(); k++)
       {
         System.out.print(" " + reflexVerts.get(k));
       }
     System.out.println();
     
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
