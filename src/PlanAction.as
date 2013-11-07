package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanAction
//
public class PlanAction
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

  public var next:PlanAction;
  public var mid:Point;

  public function PlanAction(map:TileMap, p:Point, action:String, cost:int)
  {
    this.map = map;
    this.p = p;
    this.action = action;
    this.cost = cost;
  }

  public function toString():String
  {
    return ("<PlanAction: ("+p.x+","+p.y+") action="+action+", cost="+cost+">");
  }

}

} // package
