package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;

// A 2D array used for range queries for a certain tile.
public class RangeMap 
{
  public var tilemap:TileMap;

  // _data: array for storing numbers.
  //   We just use a bitmap for space efficiency,
  //   assuming the numbers are less than its maximum color values.
  private var _data:BitmapData;

  // RangeMap(tilemap, f): constructs a range map for a given tile f.
  public function RangeMap(tilemap:TileMap, f:Function)
  {
    this.tilemap = tilemap;
    _data = new BitmapData(tilemap.width+2, 
			   tilemap.height+2, false, 0);
    for (var y:int = -1; y <= tilemap.height; y++) {
      var n:uint = 0;
      for (var x:int = -1; x <= tilemap.width; x++) {
	var n0:uint = (y<0)? 0 : _data.getPixel(x+1, y);
	if (f(tilemap.getTile(x, y))) {
	  n++;
	}
	_data.setPixel(x+1, y+1, n0+n);
      }
    }
  }

  // getCount(x0, y0, x1, y1): returns the number of tiles in the given area.
  public function getCount(x0:int, y0:int, x1:int, y1:int):uint
  {
    var t:int;
    // assert(x0 <= x1);
    if (x1 < x0) {
      t = x0; x0 = x1; x1 = t;
    }
    // assert(y0 <= y1);
    if (y1 < y0) {
      t = y0; y0 = y1; y1 = t;
    }
    x0 = Math.max(-1, Math.min(_data.width-2, x0));
    y0 = Math.max(-1, Math.min(_data.height-2, y0));
    x1 = Math.max(0, Math.min(_data.width-1, x1+1));
    y1 = Math.max(0, Math.min(_data.height-1, y1+1));
    return (_data.getPixel(x1, y1)+
	    ((x0<0 || y0<0)? 0 : _data.getPixel(x0, y0))-
	    ((y0<0)? 0 : _data.getPixel(x1, y0))-
	    ((x0<0)? 0 : _data.getPixel(x0, y1)));
  }

  // hasTile(x0, y0, x1, y1): true if there's any tile in the given area.
  public function hasTile(x0:int, y0:int, x1:int, y1:int):Boolean
  {
    return (getCount(x0, y0, x1, y1) != 0);
  }

  // hasTileByRect(r): true if a tile specified by f exists in a given range.
  public function hasTileByRect(r:Rectangle):Boolean
  {
    var r1:Rectangle = tilemap.getCoordsByRect(r);
    return hasTile(r1.left, r1.top, r1.right-1, r1.bottom-1);
  }

  // hasCollisionByRect(r, vx, vy): true if the rectangle collides with a tile.
  public function hasCollisionByRect(r:Rectangle, vx:int, vy:int):Boolean
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    return hasTileByRect(src);
  }

}

} // package
