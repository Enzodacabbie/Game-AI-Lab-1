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
     if(distance >= initialTargetDistance) { 
       initialTargetDistance = (float)distance;
     } 
     
     
     //ratio of distance left to travel over the total distance needed to be travelled
     float vScaler = (float)distance/initialTargetDistance; 
     //ratio of requiredAngle left to turn over pi
     float rScaler = requiredRotation/3.1456; 
        
     if(distance <= initialTargetDistance/2) { //if we are closer than half the distance, begin to decelerate
       vScaler = -vScaler ;
     }
     if(distance <= initialTargetDistance/3) {
        vScaler  *= 2;
     }
     if(distance <= initialTargetDistance/4) {
        vScaler  *= 2;
        if(kinematic.getSpeed() <= 20)
          vScaler = 0;
     }
     
     
     
     System.out.println(kinematic.getSpeed() + ", " + kinematic.getRotationalVelocity() + ", " + requiredRotation+ ", " + distance);
        
     if (requiredRotation <= 0.05 && requiredRotation >= -0.05) // if close to correct angle, stop rotating
     {
       kinematic.increaseSpeed(acceleration * dt * 20 * vScaler, -kinematic.getRotationalVelocity());
       kinematic.increaseSpeed(acceleration * dt * 20 * vScaler, 0);
     }
     else if (requiredRotation > 0) // if required rotation is positive, go right
     {
       kinematic.increaseSpeed(acceleration * dt * 20 * vScaler, rotational_acceleration * dt* Math.abs(rScaler));
     }
     else //turn left 
     {
       kinematic.increaseSpeed(acceleration * dt * 20 * vScaler, rotational_acceleration * dt * (-1) * Math.abs(rScaler));
     }
     if(distance <= 5) {
        kinematic.increaseSpeed(-kinematic.getSpeed(), 0);
     }

     if(followPath == true)
     {
       //handle if there is a path to follow
       
       //the first element in path will always be the current target
       //the second element is the next target in the path
       //when the target is reached, removed the first element
       
       //if there is a waypoint after current target
       if(path.get(1) != null)
       {
         //calculate the angle between the current target and next target
         double waypointX = target.x - path.get(1).x;
         double waypointY = target.y - path.get(1).y;
         
         float waypointAngle = atan2((float)waypointX, (float)waypointY);
         if(distance < 0.05) { //if we are near the current target and there is a next target
           target = path.get(1);
           path.remove(0);
         }
         
         
       }
       
     }
     /**
     if (abs((float)distance) <= 90 && abs((float)distance) > 80 && kinematic.getSpeed() > 0) // gradual slow down if moving forward
     {
       kinematic.increaseSpeed(acceleration * dt * -1 * 20, 0);
     }
     else if (abs((float)distance) <= 80 && abs((float)distance) > 75 && kinematic.getSpeed() > 0) 
     {
       kinematic.increaseSpeed(acceleration * dt * -2 *20, 0);
     }
     else if (abs((float)distance) <= 75 && kinematic.getSpeed() > 0) 
     {
       kinematic.increaseSpeed(acceleration * dt * -3 *20, 0);
     }
     else if (kinematic.getSpeed() <= 0) //if moving backwards, stop moving
     {
       kinematic.increaseSpeed(-kinematic.getSpeed(), 0);
     }
     */
  
   }
   
   void seek(PVector target)
   {
      this.target = target;
      
   }
   
   void follow(ArrayList<PVector> waypoints)
   {
      // TODO: change to follow *all* waypoints
      this.target = waypoints.get(0);
      path = waypoints;
      followPath = true;
   }
}
