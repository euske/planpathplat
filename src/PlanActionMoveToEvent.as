package {

import flash.geom.Point;
import flash.events.Event;

//  PlanActionMoveToEvent
//
public class PlanActionMoveToEvent extends Event
{
  public static const MOVETO:String = "MOVETO";

  public var p:Point;
  
  public function PlanActionMoveToEvent(p:Point)
  {
    super(MOVETO);
    this.p = p;
  }
  
}

} // package
