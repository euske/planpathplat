package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  public var dir:Point;

  // Player(image)
  public function Player(scene:Scene)
  {
    super(scene);
    dir = new Point(0, 0);
  }

  // update()
  public override function update():void
  {
    super.update();

    var v:Point = new Point(dir.x*speed, dir.y*speed);
    if (v.y < 0) {
      // move toward a nearby ladder.
      var vx1:int = hasUpperLadderNearby();
      if (vx1 != 0) {
	v.x = vx1*speed;
	v.y = 0;
      }
    } else if (0 < v.y) {
      // move toward a nearby ladder.
      var vx2:int = hasLowerLadderNearby();
      if (vx2 != 0) {
	v.x = vx2*speed;
	v.y = 0;
      }
    }
    move(v);
  }
}

} // package
