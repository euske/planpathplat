package {

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

//  TileMap class is a two dimensional array that has
//  various query functions.
//
public class TileMap
{
  // bitmap: actual bitmap to hold the 2D array.
  // The top row is used as a lookup table for tile types.
  // The color of pixel (0,0) is used as type 0.
  // The color of pixel (1,0) is used as type 1. etc.
  public var bitmap:BitmapData;

  // tilesize: the size of each tile.
  public var tilesize:int;

  // _tilevalue: lookup table from a pixel color to a type number.
  private var _tilevalue:Dictionary;
  // _rangecache: cache for range query results.
  private var _rangecache:Dictionary;

  // TileMap(bitmap, tilesize)
  public function TileMap(bitmap:BitmapData, 
			  tilesize:int)
  {
    this.bitmap = bitmap;
    this.tilesize = tilesize;

    // Construct a lookup table.
    // The color value at a pixel at (i,0) is used as i-th type.
    _tilevalue = new Dictionary();
    for (var i:int = 0; i < bitmap.width; i++) {
      var c:uint = bitmap.getPixel(i, 0);
      if (_tilevalue[c] === undefined) {
	_tilevalue[c] = i;
      }
    }
  }

  // width: returns the map width.
  public function get width():int
  {
    return bitmap.width;
  }
  // height: returns the map height.
  public function get height():int
  {
    return bitmap.height-1;
  }

  // getTile(x, y): returns the tile of a pixel at (x,y).
  public function getTile(x:int, y:int):int
  {
    if (x < 0 || bitmap.width <= x || 
	y < 0 || bitmap.height-1 <= y) {
      return -1;
    }
    var c:uint = bitmap.getPixel(x, y+1);
    return _tilevalue[c];
  }

  // setTile(x, y, i): set the tile value of pixel at (x,y).
  public function setTile(x:int, y:int, i:int):void
  {
    var c:uint = bitmap.getPixel(i, 0);
    bitmap.setPixel(x, y+1, c);
    _rangecache = null;
  }

  // isTile(x, y, f): true if the tile at (x,y) has a property given by f.
  public function isTile(x:int, y:int, f:Function):Boolean
  {
    return f(getTile(x, y));
  }
  
  // scanTile(x0, y0, x1, y1, f): returns a list of tiles that has a given property.
  //  Note: This function scans the map sequentially and is O(w*h).
  //        Use this only if an exact position of each item is needed.
  //        For a "if-exists" query, use hasTile().
  public function scanTile(x0:int, y0:int, x1:int, y1:int, f:Function):Array
  {
    var a:Array = new Array();
    var t:int;
    // assert(x0 <= x1);
    if (x1 < x0) {
      t = x0; x0 = x1; x1 = t;
    }
    // assert(y0 <= y1);
    if (y1 < y0) {
      t = y0; y0 = y1; y1 = t;
    }
    for (var y:int = y0; y <= y1; y++) {
      for (var x:int = x0; x <= x1; x++) {
	if (f(getTile(x, y))) {
	  a.push(new Point(x, y));
	}
      }
    }
    return a;
  }

  // getRangeMap(f): returns a RangeMap object for a given tile.
  //   Unlike scanTile(), this function is O(1) except for the first time being called.
  public function getRangeMap(f:Function):RangeMap
  {
    var map:RangeMap;
    if (_rangecache == null) {
	_rangecache = new Dictionary();
    }
    if (_rangecache[f] === undefined) {
      map = new RangeMap(this, f);
      _rangecache[f] = map;
    } else {
      map = _rangecache[f];
    }
    return map;
  }

  // findSimplePath(x0, y0, x1, x1, f, cb): 
  //   returns a list of points that a character can proceed without being blocked.
  //   returns null if no such path exists. This function takes O(w*h).
  //   Note: this returns only a straightforward path without any detour.
  public function findSimplePath(x0:int, y0:int, x1:int, y1:int, 
				 f:Function, cb:Rectangle):Array
  {
    var a:Array = new Array();
    var w:int = Math.abs(x1-x0);
    var h:int = Math.abs(y1-y0);
    var inf:int = (w+h+1)*2;
    var vx:int = (x0 <= x1)? +1 : -1;
    var vy:int = (y0 <= y1)? +1 : -1;
    var map:RangeMap = getRangeMap(f);
    for (var dy:int = 0; dy <= h; dy++) {
      a.push(new Array());
      // y: y0...y1
      var y:int = y0+dy*vy;
      for (var dx:int = 0; dx <= w; dx++) {
	// x: x0...x1
	var x:int = x0+dx*vx;
	// for each point, compare the cost of (x-1,y) and (x,y-1).
	var p:Point = new Point(x, y);
	var d:int;
	var e:WayPoint = null;	// the closest neighbor (if exists).
	if (dx == 0 && dy == 0) {
	  d = 0;
	} else {
	  d = inf;
	  if (!map.hasTile(x+cb.left, y+cb.top, x+cb.right, y+cb.bottom)) {
	    if (0 < dx && a[dy][dx-1].d < d) {
	      e = a[dy][dx-1];
	      d = e.d;
	    }
	    if (0 < dy && a[dy-1][dx].d < d) {
	      e = a[dy-1][dx];
	      d = e.d;
	    }
	  }
	  d++;
	}
	// populate a[dy][dx].
	a[dy].push(new WayPoint(p, d, e));
      }
    }
    // trace them in a reverse order: from goal to start.
    var r:Array = new Array();
    e = a[h][w].next;
    while (e != null) {
      r.push(e.p);
      e = e.next;
    }
    return r;
  }

  // getTilePoint(x, y): converts a point in the map to screen space.
  public function getTilePoint(x:int, y:int):Point
  {
    return new Point(x*tilesize+tilesize/2, y*tilesize+tilesize/2);
  }

  // getTileRect(x, y): converts an area in the map to screen space.
  public function getTileRect(x:int, y:int, w:int=1, h:int=1):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, w*tilesize, h*tilesize);
  }

  // getCoordsByPoint(p): converts a screen position to map coordinates.
  public function getCoordsByPoint(p:Point):Point
  {
    var x:int = Math.floor(p.x/tilesize);
    var y:int = Math.floor(p.y/tilesize);
    return new Point(x, y);
  }

  // getCoordsByRect(r): converts a screen area to a map range.
  public function getCoordsByRect(r:Rectangle):Rectangle
  {
    var x0:int = Math.floor(r.left/tilesize);
    var y0:int = Math.floor(r.top/tilesize);
    var x1:int = Math.floor((r.right+tilesize-1)/tilesize);
    var y1:int = Math.floor((r.bottom+tilesize-1)/tilesize);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }

  // scanTileByRect(r): returns a list of tiles that has a given property.
  public function scanTileByRect(r:Rectangle, f:Function):Array
  {
    r = getCoordsByRect(r);
    return scanTile(r.left, r.top, r.right-1, r.bottom-1, f);
  }

  // getCollisionByRect(r, vx, vy, f): 
  //   adjusts vector (vx,vy) so that the rectangle doesn't collide with a tile specified by f.
  public function getCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Point
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    var a:Array = scanTileByRect(src, f);
    var v:Point = new Point(vx, vy);
    for each (var p:Point in a) {
      var t:Rectangle = getTileRect(p.x, p.y);
      v = Utils.collideRect(t, r, v);
    }
    return v;
  }

}

} // package

import flash.geom.Point;

// A graph node used by findSimplePath().
class WayPoint
{
  public var p:Point;		// point.
  public var d:int;		// cost.
  public var next:WayPoint;	// next node.

  public function WayPoint(p:Point, d:int, next:WayPoint)
  {
    this.p = p;
    this.d = d;
    this.next = next;
  }
}
