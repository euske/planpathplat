package {

//  Tile
// 
public class Tile
{
  // isnone
  public static var isnone:Function = 
    (function (b:int):Boolean { return b == 0; });
  // isobstacle
  public static var isobstacle:Function = 
    (function (b:int):Boolean { return b < 0 || b == 1; });
  // isstoppable
  public static var isstoppable:Function = 
    (function (b:int):Boolean { return b != 0; });
  // isgrabbable
  public static var isgrabbable:Function = 
    (function (b:int):Boolean { return b == 2; });
}

} // package
