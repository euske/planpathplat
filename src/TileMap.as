package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

//  TileMap
//
public class TileMap extends Bitmap
{
  public var map:BitmapData;
  public var tiles:BitmapData;
  public var tilesize:int;
  public var tilewindow:Rectangle;

  private var _tilevalue:Dictionary;
  private var _mapcache:Dictionary;

  // TileMap(map, tiles, tilesize, width, height)
  public function TileMap(map:BitmapData, 
			  tiles:BitmapData,
			  tilesize:int)
  {
    this.map = map;
    this.tiles = tiles;
    this.tilesize = tilesize;
    this.tilewindow = new Rectangle();

    _tilevalue = new Dictionary();
    for (var i:int = 0; i < map.width; i++) {
      var c:uint = map.getPixel(i, 0);
      if (_tilevalue[c] === undefined) {
	_tilevalue[c] = i;
      }
    }

    _mapcache = new Dictionary();
  }

  // mapwidth
  public function get mapwidth():int
  {
    return map.width;
  }
  // mapheight
  public function get mapheight():int
  {
    return map.height-1;
  }

  // repaint(window)
  public function repaint(window:Rectangle):void
  {
    var r:Rectangle = new Rectangle(Math.floor(window.x/tilesize),
				    Math.floor(window.y/tilesize),
				    Math.floor(window.width/tilesize)+1,
				    Math.floor(window.height/tilesize)+1);
    if (!tilewindow.equals(r)) {
      tilewindow = r;
      renderTiles(tilewindow.x, tilewindow.y,
		  tilewindow.width, tilewindow.height);
    }
    this.x = (tilewindow.x*tilesize)-window.x;
    this.y = (tilewindow.y*tilesize)-window.y;
  }

  // renderTiles(x, y)
  protected function renderTiles(x0:int, y0:int, mw:int, mh:int):void
  {
    if (bitmapData == null) {
      bitmapData = new BitmapData(mw*tilesize, 
				  mh*tilesize, 
				  true, 0x00000000);
    }
    for (var dy:int = 0; dy < mh; dy++) {
      for (var dx:int = 0; dx < mw; dx++) {
	var i:int = getTile(x0+dx, y0+dy);
	var src:Rectangle = new Rectangle(i*tilesize, 0, tilesize, tilesize);
	var dst:Point = new Point(dx*tilesize, dy*tilesize);
	bitmapData.copyPixels(tiles, src, dst);
      }
    }
  }

  // getTile(x, y)
  public function getTile(x:int, y:int):int
  {
    if (x < 0 || map.width <= x || 
	y < 0 || map.height-1 <= y) {
      return -1;
    }
    var c:uint = map.getPixel(x, y+1);
    return _tilevalue[c];
  }

  // isTile(x, y, f)
  public function isTile(x:int, y:int, f:Function):Boolean
  {
    return f(getTile(x, y));
  }
  
  // scanTile(x0, y0, x1, y1, f)
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

  // hasTile(x0, y0, x1, x1, f)
  public function hasTile(x0:int, y0:int, x1:int, y1:int, f:Function):Boolean
  {
    var cache:TileMapCache;
    if (_mapcache[f] === undefined) {
      cache = new TileMapCache(this, f);
      _mapcache[f] = cache;
    } else {
      cache = _mapcache[f];
    }
    return (cache.getCount(x0, y0, x1, y1) != 0);
  }

  // getTilePoint(x, y)
  public function getTilePoint(x:int, y:int):Point
  {
    return new Point(x*tilesize+tilesize/2, y*tilesize+tilesize/2);
  }

  // getTileRect(x, y)
  public function getTileRect(x:int, y:int, w:int=1, h:int=1):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, w*tilesize, h*tilesize);
  }

  // getCoordsByPoint(p)
  public function getCoordsByPoint(p:Point):Point
  {
    var x:int = Math.floor(p.x/tilesize);
    var y:int = Math.floor(p.y/tilesize);
    return new Point(x, y);
  }

  // getCoordsByRect(r)
  public function getCoordsByRect(r:Rectangle):Rectangle
  {
    var x0:int = Math.floor(r.left/tilesize);
    var y0:int = Math.floor(r.top/tilesize);
    var x1:int = Math.floor((r.right+tilesize-1)/tilesize);
    var y1:int = Math.floor((r.bottom+tilesize-1)/tilesize);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }

  // hasTileByRect(r, f)
  public function hasTileByRect(r:Rectangle, f:Function):Boolean
  {
    var r1:Rectangle = getCoordsByRect(r);
    return hasTile(r1.left, r1.top, r1.right-1, r1.bottom-1, f);
  }

  // scanTileByRect(r)
  public function scanTileByRect(r:Rectangle, f:Function):Array
  {
    r = getCoordsByRect(r);
    return scanTile(r.left, r.top, r.right-1, r.bottom-1, f);
  }

  // getCollisionByRect(r, vx, vy, f)
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

  // hasCollisionByRect(r, f)
  public function hasCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Boolean
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    return hasTileByRect(src, f);
  }

  // findPath(x0, y0, x1, x1, f, b)
  public function findPath(x0:int, y0:int, x1:int, y1:int, f:Function, cb:Rectangle):Array
  {
    var a:Array = new Array();
    var w:int = Math.abs(x1-x0);
    var h:int = Math.abs(y1-y0);
    var inf:int = (w+h+1)*2;
    var vx:int = (x0 <= x1)? +1 : -1;
    var vy:int = (y0 <= y1)? +1 : -1;
    for (var dy:int = 0; dy <= h; dy++) {
      a.push(new Array());
      var y:int = y0+dy*vy;
      for (var dx:int = 0; dx <= w; dx++) {
	var x:int = x0+dx*vx;
	var p:Point = new Point(x, y);
	var e:PathEntry = null;
	var d:int;
	if (dx == 0 && dy == 0) {
	  d = 0;
	} else {
	  d = inf;
	  if (!hasTile(x+cb.left, y+cb.top, x+cb.right, y+cb.bottom, f)) {
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
	a[dy].push(new PathEntry(p, d, e));
      }
    }
    var r:Array = new Array();
    e = a[h][w].next;
    while (e != null) {
      r.push(e.p);
      e = e.next;
    }
    return r;
  }

}

} // package


import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;

class TileMapCache 
{
  private var _data:BitmapData;

  public function TileMapCache(tilemap:TileMap, f:Function)
  {
    _data = new BitmapData(tilemap.mapwidth+2, 
			   tilemap.mapheight+2, false, 0);
    for (var y:int = -1; y <= tilemap.mapheight; y++) {
      var n:uint = 0;
      for (var x:int = -1; x <= tilemap.mapwidth; x++) {
	var n0:uint = (y<0)? 0 : _data.getPixel(x+1, y);
	if (f(tilemap.getTile(x, y))) {
	  n++;
	}
	_data.setPixel(x+1, y+1, n0+n);
      }
    }
  }

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
}

class PathEntry
{
  public var p:Point;
  public var d:int;
  public var next:PathEntry;
  public function PathEntry(p:Point, d:int, next:PathEntry)
  {
    this.p = p;
    this.d = d;
    this.next = next;
  }
}
