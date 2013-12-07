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
  public var context:String;
  public var type:String;
  public var cost:int;
  public var next:PlanAction;

  public function PlanAction(p:Point, context:String=null,
			     type:String=NONE, cost:int=0, 
			     next:PlanAction=null)
  {
    this.p = p;
    this.context = context;
    this.type = type;
    this.cost = cost;
    this.next = next;
  }

  public function toString():String
  {
    return ("<PlanAction: ("+p.x+","+p.y+") type="+type+", cost="+cost+">");
  }

  public function get key():String
  {
    return getKey(p.x, p.y, context);
  }

  // getKey(x, y, context)
  public static function getKey(x:int, y:int, context:String=null):String
  {
    return x+","+y+":"+context
  }

}

} // package
