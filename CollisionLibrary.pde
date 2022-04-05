
/////////
// Point Intersection Tests
/////////

//Returns true iff the point, pointPos, is inside the box defined by boxTopLeft, boxW, and boxH
boolean pointInBox(Vec2 boxTopLeft, float boxW, float boxH, Vec2 pointPos){
  float boxXPos = boxTopLeft.x + boxW;
  float boxYPos = boxTopLeft.y + boxH;
  if(pointPos.x >= boxTopLeft.x && pointPos.y >= boxTopLeft.y){
    if(pointPos.x <= boxXPos && pointPos.y <= boxYPos){
      return true;
    }
  }
  return false;
}

//Returns true iff the point, pointPos, is inside a circle defined by center and radius r
// If eps is non-zero, count the point as "inside" the circle if the point is outside, but within the distance eps of the edge
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
  if (pointPos.distanceTo(center) <= (r+eps)){
    return true;
  }
  return false;
}

//Returns true if the point is inside any of the circles defined by the list of centers,"centers", and corisponding radii, "radii".
// As above, count point within "eps" of the circle as inside the circle
//Only check the first "numObstacles" circles.
boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
  for (int i = 0; i < numObstacles; i++){
    if (pointPos.distanceTo(centers[i]) <= (radii[i] + eps)){
      return true;
    }
  }
  return false;
}


/////////
// Ray Intersection Tests
/////////

//This struct is used for ray-obstaclce intersection.
//It store both if there is a collision, and how far away it is (int terms of distance allong the ray)
class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits the circle centered at "center", with a radius "radius".
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized
hitInfo rayCircleIntersect(Vec2 center, float radius, Vec2 ray_start, Vec2 ray_dir, float max_t){
  hitInfo hit = new hitInfo();
  Vec2 toCircle;
  float a, b, c, d, t;
  
  toCircle = center.minus(ray_start);
  a = ray_dir.length();
  b = -2*dot(ray_dir,toCircle);
  c = toCircle.lengthSqr() - (radius * radius);
  
  d = b*b - 4*a*c;
  
  if (d >= 0){
    t = (-b - sqrt(d))/(2*a);
    if (t >= 0 && t <= max_t){
      hit.hit = true;
      hit.t = t;
    }
  }
  return hit;
}

//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits any of the circles defined by the list of centers,"centers", and corisponding radii, "radii"
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized
//Only check the first "numObstacles" circles.
hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii, int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  Vec2 toCircle;
  float a, b, c, d, t;
  
  for (int i = 0; i < numObstacles; i++){
    toCircle = centers[i].minus(l_start);
    a = l_dir.length();
    b = -2*dot(l_dir, toCircle);
    c = toCircle.lengthSqr() - (radii[i] * radii[i]);
    
    d = b*b - 4*a*c;
    
    if (d >= 0){
      t = (-b - sqrt(d))/(2*a);
      if (t >= 0 && t <= max_t){
        if(hit.t == 9999999){
          hit.hit = true;
          hit.t = t;
        }
        else if (t < hit.t){
          hit.hit = true;
          hit.t = t;
        }
      }
    }
  }
  
  return hit;
}
