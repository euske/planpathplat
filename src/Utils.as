package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Utility Functions
// 
public class Utils
{
  // collideHLine: Computes the collision of two horizontal lines.
  private static function collideHLine(x0:int, x1:int, y:int, r:Rectangle, v:Point):Point
  {
    var dy:int;
    if (y <= r.top && r.top < y+v.y) {
      dy = r.top - y;
    } else if (r.bottom <= y && y+v.y < r.bottom) {
      dy = r.bottom - y;
    } else {
      return v;
    }
    // assert(v.y != 0);
    var dx:int = Math.floor(v.x*dy / v.y);
    if ((v.x <= 0 && x1+dx <= r.left) ||
	(0 <= v.x && r.right <= x0+dx) ||
	(x1+dx < r.left || r.right < x0+dx)) {
      return v;
    }
    return new Point(dx, dy);
  }

  // collideVLine: Computes the collision of two vertical lines.
  private static function collideVLine(y0:int, y1:int, x:int, r:Rectangle, v:Point):Point
  {
    var dx:int;
    if (x <= r.left && r.left < x+v.x) {
      dx = r.left - x;
    } else if (r.right <= x && x+v.x < r.right) {
      dx = r.right - x;
    } else {
      return v;
    }
    // assert(v.x != 0);
    var dy:int = Math.floor(v.y*dx / v.x);
    if ((v.y <= 0 && y1+dy <= r.top) ||
	(0 <= v.y && r.bottom <= y0+dy) ||
	(y1+dy < r.top || r.bottom < y0+dy)) {
      return v;
    }
    return new Point(dx, dy);
  }

  // collideRect(r0, r1, v):
  //   Trims vector v to v' such that Rectangle r0 doesn't overlap with r1 
  //   when it moves by v'.
  // Note: r0 and r1 should not be overlapping.
  public static function collideRect(r0:Rectangle, r1:Rectangle, v:Point):Point
  {
    if (0 < v.x) {
      v = collideVLine(r1.top, r1.bottom, r1.right, r0, v);
    } else if (v.x < 0) {
      v = collideVLine(r1.top, r1.bottom, r1.left, r0, v);
    }
    if (0 < v.y) {
      v = collideHLine(r1.left, r1.right, r1.bottom, r0, v);
    } else if (v.y < 0) {
      v = collideHLine(r1.left, r1.right, r1.top, r0, v);
    }
    return v;
  }

  // movePoint(r, dx, dy): translates a Point.
  public static function movePoint(p:Point, dx:int, dy:int):Point
  {
    p = p.clone();
    p.x += dx;
    p.y += dy;
    return p;
  }

  // moveRect(r, dx, dy): translates a Rectangle.
  public static function moveRect(r:Rectangle, dx:int, dy:int):Rectangle
  {
    r = r.clone();
    r.x += dx;
    r.y += dy;
    return r;
  }

  // clamp(v0, v, v1): caps the value between upper/lower bounds.
  public static function clamp(v0:int, v:int, v1:int):int
  {
    return Math.min(Math.max(v, v0), v1);
  }
  
}

} // package
