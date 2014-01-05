package {

//  This class provides a set of functions that test 
//  if a block has a certain property.
// 
public class Tile
{
  // isNone(b): true if b is empty.
  public static var isNone:Function = 
    (function (b:int):Boolean { return b == 0; });

  // isObstacle(b): true if b is an obstacle.
  public static var isObstacle:Function = 
    (function (b:int):Boolean { return b < 0 || b == 1; });

  // isStoppable(b): true if b blocks jumping/falling.
  public static var isStoppable:Function = 
    (function (b:int):Boolean { return b != 0; });

  // isGrabbable(b): true if b is a ladder.
  public static var isGrabbable:Function = 
    (function (b:int):Boolean { return b == 2; });

}

} // package
