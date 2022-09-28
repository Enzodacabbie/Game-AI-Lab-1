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
        float angle = atan2(  target.y- kinematic.position.y,  target.x -  kinematic.position.y);
        //normalize the angle
        angle = normalize_angle(angle);
        double requiredRotation = angle-kinematic.getHeading();
        
        double deltaX = target.x - kinematic.position.x; 
        double deltaY = target.y - kinematic.position.y;
        
        //calculate the distance to the target by taking the square root of sum of squared delta distances
        double distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
        
        //float constant;
        System.out.println(requiredRotation + ", " + kinematic.getRotationalVelocity());
        
          //kinematic.increaseSpeed(acceleration * dt * 80, rotational_acceleration * dt);
          if(requiredRotation <= 0.05 && requiredRotation >= -0.05)
          {
            kinematic.increaseSpeed(acceleration * dt * (float)distance, -kinematic.getRotationalVelocity());
            kinematic.increaseSpeed(acceleration * dt * (float)distance, 0);
          }
          else
          {
            kinematic.increaseSpeed(acceleration * dt * (float)distance, rotational_acceleration * dt * (float)angle);
          }
       
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
   
   void seek(PVector target)
   {
      this.target = target;
      
   }
   
   void follow(ArrayList<PVector> waypoints)
   {
      // TODO: change to follow *all* waypoints
      this.target = waypoints.get(0);
      
   }
}
