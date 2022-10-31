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

class NavMeshEdge
{
  Wall wall;
  int origin;
  int end;
  
  NavMeshEdge(Wall w, int o, int e) 
  {
    wall = w;
    origin = o;
    end = e;
  }
} //<>//



class NavMesh
{   
   //contains the indices of all the vertices that are reflex in map
   ArrayList<Integer> reflexAngles;
   
   //contains the walls added when creating the navmesh
   ArrayList<NavMeshEdge> navMeshWalls;
   
   ArrayList<ArrayList<Wall>> polygons;
   void bake(Map map)
   {
     
     reflexAngles  = new ArrayList<Integer>();
     navMeshWalls = new ArrayList<NavMeshEdge>();
     polygons = new ArrayList<ArrayList<Wall>>();
     
     for(int i = 0; i < map.walls.size()-1; i++)  //<>//
     { //we do not need to check the last edge as it is the bottom left corner
       float direction = map.walls.get(i).normal.dot(map.walls.get(i+1).direction); //get dot product of the current edge normal to the next edge
       
       //assign the index of each wall to its index in the array
       map.walls.get(i).index = i;
       
       if(direction > 0) 
       { //if the dot product is positive, then the angle between the edges is reflex
         reflexAngles.add(i); 
         
         float maxDistance = 0;
         int targetEdge = 0;
         for(int j = 0; j < map.walls.size(); j++) 
         {
           if(j != i && j!= (i + 2)) //do not check neighboring vertices
           {
             float deltaX =  map.walls.get(j).start.x - map.walls.get(i).end.x;
             float deltaY =  map.walls.get(j).start.y - map.walls.get(i).end.y;
             double distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY)); //calculate distance between current vertex and other vertices
             
             Wall testWall = new Wall(map.walls.get(i).end, map.walls.get(j).start);
             PVector testStart = PVector.add(testWall.start, PVector.mult(testWall.direction, 0.05));
             PVector testEnd = PVector.add(testWall.end, PVector.mult(testWall.direction, -0.05));
             testWall = new Wall(testStart, testEnd);
             
             if(distance > maxDistance && !map.collides(testWall.start, testWall.end) && isPointInPolygon(testWall.center(), map.walls)) 
             {
               if(navMeshWalls.size() == 0) 
               {
                 
                 maxDistance = (float)distance;
                 targetEdge = j;
               }
               else 
               {
                 boolean clean = true;
                 
                 for(NavMeshEdge w : navMeshWalls)
                 {
                   if(testWall.crosses(w.wall.start, w.wall.end)) 
                   {
                     clean = false;
                   }
                 }
                 
                 if(clean == true)
                 {
                   
                   maxDistance = (float)distance;
                   targetEdge = j;
                 } 
               }
               
             }
           }
         }
         
         //finished looking through all the walls and found the vertex with the further distance that is connectable
         Wall addWall = new Wall(map.walls.get(targetEdge).start, map.walls.get(i).end);
         addWall.index = map.walls.size()-1 + navMeshWalls.size();
         NavMeshEdge nmEdge = new NavMeshEdge(addWall, targetEdge, i);
         
         navMeshWalls.add(nmEdge); //<>//
         
         
         
         //check if the angle is still reflex with the new wall
         float d = addWall.normal.dot(map.walls.get(i+1).direction);
         boolean stillReflex = false;
         if(d > 0) 
         {
           //if the dot between the new wall and the 
           stillReflex = false;
           System.out.println("still reflex at: " + i);
         }
         
         if(stillReflex == true) 
         {
           float minDistance = 999;
           int target = 0;
           
           System.out.println("here");
           for(int j = 0; j < map.walls.size(); j++) 
           {
             if(j != i && j!= (i + 1) && j != targetEdge ) //do not check neighboring vertices
             {
               float deltaX =  map.walls.get(j).start.x - map.walls.get(i).end.x;
               float deltaY =  map.walls.get(j).start.y - map.walls.get(i).end.y;
               double distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY)); //calculate distance between current vertex and other vertices
             
               Wall testWall = new Wall(map.walls.get(i).end, map.walls.get(j).start);
               PVector testStart = PVector.add(testWall.start, PVector.mult(testWall.direction, 0.05));
               PVector testEnd = PVector.add(testWall.end, PVector.mult(testWall.direction, -0.05));
               testWall = new Wall(testStart, testEnd);
               System.out.println("here1");

             
               if(distance < minDistance && !map.collides(testWall.start, testWall.end) && isPointInPolygon(testWall.center(), map.walls)) 
               {
                 System.out.println("here 2");
                 if(navMeshWalls.size() == 0) 
                 {
                 
                   minDistance = (float)distance;
                   target = j;
                 }
                 else 
                 {
                   boolean clean = true;
                 
                   for(NavMeshEdge w : navMeshWalls)
                   {
                     if(testWall.crosses(w.wall.start, w.wall.end)) 
                     {
                       clean = false;
                     }
                   }
                   System.out.println(clean);
                 
                   if(clean == true)
                   {
                     minDistance = (float)distance;
                     target = j;
                     System.out.println("hello");
                     
                   } 
                 }
               }
             }
           }
           
           Wall wall = new Wall(map.walls.get(target).start, map.walls.get(i).end);
           wall.index = map.walls.size()-1 + navMeshWalls.size();
           
           NavMeshEdge nmEdge2 = new NavMeshEdge(wall,target, i);
           navMeshWalls.add(nmEdge2);
                     
         }
           
        }
        
        //create polygons
        /**
        for(Wall w in navMeshWalls) 
        {
          
        }
        */
      }
    
   }
   
   int getIndex(ArrayList<Wall> walls, int index) 
   {
     if (index >= walls.size()) 
       index = index % walls.size();
      else if(index < 0)
        index = index % walls.size() + walls.size();
      return index;
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
        line(navMeshWalls.get(i).wall.start.x, navMeshWalls.get(i).wall.start.y, navMeshWalls.get(i).wall.end.x, navMeshWalls.get(i).wall.end.y);
        //stroke(#eb4034);
      }
   }
}
