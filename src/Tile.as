package {

//  Tile
// 
public class Tile
{
  // isNone
  public static var isNone:Function = 
    (function (b:int):Boolean { return b == 0; });

  // isObstacle
  public static var isObstacle:Function = 
    (function (b:int):Boolean { return b < 0 || b == 1; });

  // isStoppable
  public static var isStoppable:Function = 
    (function (b:int):Boolean { return b != 0; });

  // isGrabbable
  public static var isGrabbable:Function = 
    (function (b:int):Boolean { return b == 2; });

}

} // package
