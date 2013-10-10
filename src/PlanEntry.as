package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanEntry
//
public class PlanEntry
{
  public static const NONE:String = "NONE";
  public static const WALK:String = "WALK";
  public static const FALL:String = "FALL";
  public static const CLIMB:String = "CLIMB";
  public static const JUMP:String = "JUMP";

  public var map:TileMap;
  public var p:Point;
  public var action:String;
  public var cost:int;

  public var next:PlanEntry;
  public var arg:Object;

  public function PlanEntry(map:TileMap, p:Point, action:String, cost:int)
  {
    this.map = map;
    this.p = p;
    this.action = action;
    this.cost = cost;
  }

  public function toString():String
  {
    return ("<PlanEntry: ("+p.x+","+p.y+") action="+action+", cost="+cost+">");
  }

  public function hasObstacle(src:Point, cb:Rectangle):Boolean
  {
    var mid:Point = getDestination(src);
    var x0:int = Math.min(src.x+cb.left, mid.x);
    var x1:int = Math.max(src.x+cb.right, mid.x);
    var y0:int = Math.min(src.y+cb.top, mid.y);
    var y1:int = Math.max(src.y+cb.bottom, mid.y);
    Main.log("bounds="+x0+","+y0+"-"+x1+","+y1);
    return map.hasTile(x0, y0, x1, y1, Tile.isstoppable);
  }

  public function getDestination(src:Point):Point
  {
    var mid:Point = Point(arg);
    if (mid != null &&
	inbetween(p.x, src.x, mid.x) &&
	inbetween(p.y, src.y, mid.y)) {
      return mid;
    } else {
      return next.p;
    }
  }

  private function inbetween(v0:int, v:int, v1:int):Boolean
  {
    return ((v0 <= v && v <= v1) || 
	    (v1 <= v && v <= v0));
  }

}

} // package
