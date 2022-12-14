/// In this file, you will have to implement seek and waypoint-following
/// The relevant locations are marked with "TODO"

class Crumb
{
  PVector position;
  Crumb(PVector position)
  {
     this.position = position;
  }
  void draw()
  {
     fill(255);
     noStroke(); 
     circle(this.position.x, this.position.y, CRUMB_SIZE);
  }
}

class Boid
{
   Crumb[] crumbs = {};
   int last_crumb;
   float acceleration;
   float rotational_acceleration;
   KinematicMovement kinematic;
   PVector target;
   ArrayList<PVector> path;
   boolean followPath;
   float initialTargetDistance = 0;
   float topSpeed = 0;
   float topRotSpeed = 0;
   
   Boid(PVector position, float heading, float max_speed, float max_rotational_speed, float acceleration, float rotational_acceleration)
   {
     this.kinematic = new KinematicMovement(position, heading, max_speed, max_rotational_speed);
     this.last_crumb = millis();
     this.acceleration = acceleration;
     this.rotational_acceleration = rotational_acceleration;
   }

   void update(float dt)
   {
     if (target != null)
     {  
        move(dt);
     }
     
     // place crumbs, do not change     
     if (LEAVE_CRUMBS && (millis() - this.last_crumb > CRUMB_INTERVAL))
     {
        this.last_crumb = millis();
        this.crumbs = (Crumb[])append(this.crumbs, new Crumb(this.kinematic.position));
        if (this.crumbs.length > MAX_CRUMBS)
           this.crumbs = (Crumb[])subset(this.crumbs, 1);
     }
     
     // do not change
     this.kinematic.update(dt);
     
     draw();
   }
   
   void draw()
   {
     for (Crumb c : this.crumbs)
     {
       c.draw();
     }
     
     fill(255);
     noStroke(); 
     float x = kinematic.position.x;
     float y = kinematic.position.y;
     float r = kinematic.heading;
     circle(x, y, BOID_SIZE);
     // front
     float xp = x + BOID_SIZE*cos(r);
     float yp = y + BOID_SIZE*sin(r);
     
     // left
     float x1p = x - (BOID_SIZE/2)*sin(r);
     float y1p = y + (BOID_SIZE/2)*cos(r);
     
     // right
     float x2p = x + (BOID_SIZE/2)*sin(r);
     float y2p = y - (BOID_SIZE/2)*cos(r);
     triangle(xp, yp, x1p, y1p, x2p, y2p);
   } 
   
   void move(float dt)
   {
     
     double deltaX = target.x - kinematic.position.x; 
     double deltaY = target.y - kinematic.position.y;
     
     //find angle between from the boid to the target in relation to the the x axis
     float angle = atan2((float)deltaY, (float)deltaX); 
     
     //find angle to turn from the angle 
     float requiredRotation = normalize_angle_left_right(angle - kinematic.getHeading());
     
     //calculate the distance to the target by taking the square root of sum of squared delta distances
     double distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
     
     //since the boid always moves closer to the target, the distance is largest at its initial 
     if(distance >= initialTargetDistance) 
     { 
       initialTargetDistance = (float)distance;
     } 
     
     //ratio of distance left to travel over the total distance needed to be travelled
     float vScaler = (float)distance/initialTargetDistance; 
     //ratio of PI over required angle to turn
     float rScaler = PI/requiredRotation;
    
     
     if (kinematic.getSpeed() > topSpeed) 
       topSpeed = kinematic.getSpeed();
       
     float x = 5;
     float movement = acceleration * dt * x * initialTargetDistance; //multiply by initialTargetDistance as the further we are initially, the faster we want to accelerate
     
     
     if (vScaler < 0.5) //if we are less than half the starting distance away, then start to decelerate
     { 
       x = -x;
       
       if(kinematic.getSpeed() <= topSpeed/2) //if we reach the minimum threshold speed for this radius, stop decelerating
       { 
         x = 0;
       }
       
       //when making waypoint turns, if the angle to turn is within a certain range and boid is moving too slowly (basically stopping)
       //then speed up a bit 
       if(path.size()>1 && requiredRotation >= -0.03 && requiredRotation <= 0.03 && kinematic.getSpeed() < 25)
         {
          x = 0.25;
         }
     } 
     
     
     
     if(vScaler < 0.1) //if we are less than 10% of the original distance away, decelerate even further
     { 
       x = -25;
       if(kinematic.getSpeed() <= topSpeed/5) //if we reach the minimum threshold speed for this radius, stop decelerating
       {
         x = 0;
       }
         
         //when making waypoint turns, if the angle to turn is within a certain range and boid is moving too slowly (basically stopping)
         //then speed up a bit 
         if(path.size()>1 && requiredRotation >= -0.04 && requiredRotation <= 0.04 && kinematic.getSpeed() < 20)
         {
          x = 1;

         } 
     }
       movement = acceleration * dt * x;
       
     //Uncomment to view speeds and rotations
     //System.out.println(kinematic.getSpeed() + ", " + kinematic.getRotationalVelocity() + ", " + requiredRotation+ ", " + topSpeed);
        
     if (requiredRotation <= 0.05 && requiredRotation >= -0.05) // if close to correct angle, stop rotating
     {
       kinematic.increaseSpeed(movement, -kinematic.getRotationalVelocity());
     }
     else if (requiredRotation > 0) // if required rotation is positive, go right
     {                              // rotational acceleration is multiplied by PI/requiredRotation so that turn speeds are scaled according to the angle
       kinematic.increaseSpeed(movement, rotational_acceleration * dt* Math.abs(rScaler));
     }
     else //turn left 
     {
       kinematic.increaseSpeed(movement, rotational_acceleration * dt * (-1) * Math.abs(rScaler));
     }
     if(distance <= 5) {
        kinematic.increaseSpeed(-kinematic.getSpeed(), -kinematic.getRotationalVelocity());
        topSpeed = 0;
        initialTargetDistance = 0;
     }

     if(followPath == true)
     {
       //handle if there is a path to follow
       
       //the first element in path will always be the current target
       //the second element is the next target in the path
       //when the target is reached, removed the first element
       
       //if there is a waypoint after current target
       if(path.size() > 1)
       {
         if(distance < 10) { //if we are near the current target and there is a next target
           topSpeed = 0;
           initialTargetDistance = 0;
           this.target = path.get(1);
           path.remove(0);
         }
         
         
       }
       
     }
  
   }
   
   void seek(PVector target)
   {
     ArrayList<PVector> waypoints = nm.findPath(kinematic.position, target);
      this.target = waypoints.get(0);
      path = waypoints;
      followPath = true;
      
   }
   
   void follow(ArrayList<PVector> waypoints)
   {
      this.target = waypoints.get(0);
      path = waypoints;
      followPath = true;
   }
   
}
