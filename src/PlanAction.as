package {

import flash.geom.Point;

//  PlanAction
//
public class PlanAction
{
  public static const NONE:String = "NONE";
  public static const WALK:String = "WALK";
  public static const FALL:String = "FALL";
  public static const CLIMB:String = "CLIMB";
  public static const JUMP:String = "JUMP";

  public var p:Point;
  public var type:String;
  public var cost:int;

  public var next:PlanAction;
  public var mid:Point;

  public function PlanAction(p:Point, type:String, cost:int)
  {
    this.p = p;
    this.type = type;
    this.cost = cost;
  }

  public function toString():String
  {
    return ("<PlanAction: ("+p.x+","+p.y+") type="+type+", cost="+cost+">");
  }

}

} // package
