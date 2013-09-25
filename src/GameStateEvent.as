package {

import flash.events.Event;

//  GameStateEvent
//
public class GameStateEvent extends Event
{
  public static const CHANGED:String = "GameStateEvent.CHANGED";

  public var name:String;
  
  public function GameStateEvent(name:String)
  {
    super(CHANGED);
    this.name = name;
  }
  
}

} // package
