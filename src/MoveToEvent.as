package {

import flash.geom.Point;
import flash.events.Event;

//  MoveToEvent
//
public class MoveToEvent extends Event
{
  public var p:Point;
  
  public function MoveToEvent(type:String, p:Point)
  {
    super(type);
    this.p = p;
  }
  
}

} // package
