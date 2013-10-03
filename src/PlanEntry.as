package {

import flash.geom.Point;

//  PlanEntry
//
public class PlanEntry
{
  public static const NONE:String = "NONE";
  public static const WALK:String = "WALK";
  public static const FALL:String = "FALL";
  public static const CLIMB:String = "CLIMB";
  public static const JUMP:String = "JUMP";

  public var p:Point;
  public var action:String;
  public var cost:int;
  public var next:PlanEntry;
  public var arg:Object;

  public function PlanEntry(p:Point, action:String, cost:int, next:PlanEntry)
  {
    this.p = p;
    this.action = action;
    this.cost = cost;
    this.next = next;
  }

  public function toString():String
  {
    return ("<PlanEntry: ("+p.x+","+p.y+") action="+action+", cost="+cost+">");
  }
}

} // package
