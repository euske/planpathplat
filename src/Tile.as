package {

//  This class provides a set of functions that test 
//  if a block has a certain property.
// 
public class Tile
{
  public static const NONE:int = 0;
  public static const BLOCK:int = 1;
  public static const LADDER:int = 2;

  public static const PLAYER:int = 3;
  public static const ENEMY1:int = 4;
  public static const ENEMY2:int = 5;

  // isNone(b): true if b is empty.
  public static var isNone:Function = 
    (function (b:int):Boolean { return b == NONE || 3 <= b });

  // isObstacle(b): true if b is an obstacle.
  public static var isObstacle:Function = 
    (function (b:int):Boolean { return b < 0 || b == BLOCK; });

  // isStoppable(b): true if b blocks jumping/falling.
  public static var isStoppable:Function = 
    (function (b:int):Boolean { return b == BLOCK || b == LADDER });

  // isGrabbable(b): true if b is a ladder.
  public static var isGrabbable:Function = 
    (function (b:int):Boolean { return b == LADDER; });

}

} // package
