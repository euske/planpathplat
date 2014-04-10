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
    dir = new Point();
  }

  // update()
  public override function update():void
  {
    super.update();
    fall();

    var p:Point, t:Rectangle;
    var v:Point = new Point(dir.x*speed, dir.y*speed);
    var r:Rectangle = getMovedBounds(v.x, v.y);
    var a:Array = tilemap.scanTileByRect(r, Tile.isObstacle);
    if (v.x != 0 && v.y == 0) {
      // moved left/right.
      var y0:int = r.top;
      var y1:int = r.bottom;
      for each (p in a) {
	t = tilemap.getTileRect(p.x, p.y);
	if (t.top < y0) {
	  y0 = Math.max(y0, t.bottom);
	} else if (y1 < t.bottom) {
	  y1 = Math.min(y1, t.top);
	}
      }
      if (r.top < y0 && y1 == r.bottom) {
	v.x = 0; v.y = Math.min(+speed, y0-r.top); 
      } else if (y0 == r.top && y1 < r.bottom) {
	v.x = 0; v.y = Math.max(-speed, y1-r.bottom);
      }

    } else if (v.x == 0 && v.y != 0) {
      // moved up/down.
      var x0:int = r.left;
      var x1:int = r.right;
      for each (p in a) {
	t = tilemap.getTileRect(p.x, p.y);
	if (t.left < x0) {
	  x0 = Math.max(x0, t.right);
	} else if (x1 < t.right) {
	  x1 = Math.min(x1, t.left);
	}
      }
      if (r.left < x0 && x1 == r.right) {
	v.x = Math.min(+speed, x0-r.left); v.y = 0;
      } else if (x0 == r.left && x1 < r.right) {
	v.x = Math.max(-speed, x1-r.right); v.y = 0;
      }
    }
    move(v);
  }
}

} // package
