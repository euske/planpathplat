package {

import flash.events.Event;

//  ScreenEvent
//
public class ScreenEvent extends Event
{
  public static const CHANGED:String = "ScreenEvent.CHANGED";

  public var name:String;
  
  public function ScreenEvent(name:String)
  {
    super(CHANGED);
    this.name = name;
  }
  
}

} // package
