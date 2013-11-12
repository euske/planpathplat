package {

import flash.geom.Point;
import flash.events.Event;

//  PlanActionJumpEvent
//
public class PlanActionJumpEvent extends Event
{
  public static const JUMP:String = "JUMP";

  public function PlanActionJumpEvent()
  {
    super(JUMP);
  }
  
}

} // package
