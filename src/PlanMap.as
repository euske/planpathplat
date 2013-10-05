package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var map:TileMap;
  public var start:Point;
  public var goal:Point;
  public var bounds:Rectangle;

  private var _a:Array;

  // PlanMap(map, goal, bounds)
  public function PlanMap(map:TileMap, goal:Point, bounds:Rectangle)
  {
    this.map = map;
    this.goal = goal;
    this.bounds = bounds;
    _a = new Array(bounds.height+1);
    var maxcost:int = (bounds.width+bounds.height+1)*2;
    for (var y:int = bounds.top; y <= bounds.bottom; y++) {
      var b:Array = new Array(bounds.width+1);
      for (var x:int = bounds.left; x <= bounds.right; x++) {
	var p:Point = new Point(x, y);
	b[x-bounds.left] = new PlanEntry(p, PlanEntry.NONE, maxcost, null);
      }
      _a[y-bounds.top] = b;
    }
  }

  public function toString():String
  {
    return ("<PlanMap ("+bounds.left+","+bounds.top+")-("+
	    bounds.right+","+bounds.bottom+")>");
  }

  // getEntry(x, y)
  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < bounds.left || bounds.right < x ||
	y < bounds.top || bounds.bottom < y) return null;
    return _a[y-bounds.top][x-bounds.left];
  }

  // addPlan(plan, b)
  public function addPlan(cb:Rectangle, 
			   jumpdt:int, speed:int, gravity:int,
			   start:Point=null, n:int=1000,
			   falldx:int=10, falldy:int=20):int
  {
    var jumpdx:int = Math.floor(jumpdt*speed / map.tilesize);
    var jumpdy:int = -Math.floor(jumpdt*(jumpdt+1)/2 * gravity / map.tilesize);

    if (start != null &&
	!map.hasTile(start.x+cb.left, start.y+cb.bottom+1, 
		     start.x+cb.right, start.y+cb.bottom+1, 
		     Tile.isstoppable)) return 0;
    this.start = start;
    
    var e1:PlanEntry = _a[goal.y-bounds.top][goal.x-bounds.left];
    e1.cost = 0;
    var queue:Array = [ new QueueItem(e1) ];
    while (0 < n && 0 < queue.length) {
      var cost:int;
      var q:QueueItem = queue.pop();
      var e0:PlanEntry = q.entry;
      var p:Point = e0.p;
      if (start != null && start.equals(p)) break;
      if (map.hasTile(p.x+cb.left, p.y+cb.top, 
		      p.x+cb.right, p.y+cb.bottom, 
		      Tile.isobstacle)) continue;
      if (!map.hasTile(p.x+cb.left, p.y+cb.bottom+1, 
		       p.x+cb.right, p.y+cb.bottom+1, 
		       Tile.isstoppable)) continue;
      // assert(bounds.left <= p.x && p.x <= bounds.right);
      // assert(bounds.top <= p.y && p.y <= bounds.bottom);

      // try climbing down.
      if (bounds.top <= p.y-1 &&
	  map.isTile(p.x, p.y+cb.bottom, Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top-1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(new QueueItem(e1, start));
	}
      }
      // try climbing up.
      if (p.y+1 <= bounds.bottom &&
	  map.hasTile(p.x+cb.left, p.y+cb.top+1,
		      p.x+cb.right, p.y+cb.bottom+1,
		      Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top+1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(new QueueItem(e1, start));
	}
      }

      // for left and right.
      for (var vx:int = -1; vx <= +1; vx += 2) {
	var bx0:int = (0 < vx)? cb.left : cb.right;
	var bx1:int = (0 < vx)? cb.right : cb.left;

	// try walking.
	var wx:int = p.x-vx;
	if (bounds.left <= wx && wx <= bounds.right &&
	    map.hasTile(wx+cb.left, p.y+cb.bottom+1,
			wx+cb.right, p.y+cb.bottom+1,
			Tile.isstoppable)) {
	  e1 = _a[p.y-bounds.top][wx-bounds.left];
	  cost = e0.cost+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.WALK;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(new QueueItem(e1, start));
	  }
	}

	// try falling.
	for (fdx = 1; fdx <= falldx; fdx++) {
	  fx = p.x-vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) break;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) break;
	    if (!map.hasTile(fx+cb.left, fy+cb.bottom+1, 
			     fx+cb.right, fy+cb.bottom+1, 
			     Tile.isstoppable)) continue;
	    if (map.hasTile(p.x+bx1, p.y+cb.bottom,
			    fx+bx0+vx, fy+cb.top, 
			    Tile.isstoppable)) continue;
	    e1 = _a[fy-bounds.top][fx-bounds.left];
	    cost = e0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	    if (cost < e1.cost) {
	      e1.action = PlanEntry.FALL;
	      e1.cost = cost;
	      e1.next = e0;
	      queue.push(new QueueItem(e1, start));
	    }
	  }
	}

	// try jumping + falling.
	var fx:int, fy:int;
	var fdt:int, fdx:int, fdy:int;
	for (fdx = 0; fdx <= falldx; fdx++) {
	  fx = p.x-vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) break;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) break;
	    if (map.hasTile(p.x+bx1, p.y+cb.bottom, 
			    fx, fy+cb.top, 
			    Tile.isstoppable)) continue;
	    for (var jdx:int = 1; jdx <= jumpdx; jdx++) {
	      var jx:int = fx-vx*jdx;
	      if (jx < bounds.left || bounds.right < jx) continue;
	      var jy:int = fy-jumpdy;
	      if (jy < bounds.top || bounds.bottom < jy) continue;
	      if (!map.hasTile(jx+cb.left, jy+cb.bottom+1, 
			       jx+cb.right, jy+cb.bottom+1, 
			       Tile.isstoppable)) continue;
	      if (map.hasTile(fx+bx1-vx, fy+cb.top, 
			      jx+bx0, jy+cb.bottom, 
	      		      Tile.isstoppable)) continue;
	      e1 = _a[jy-bounds.top][jx-bounds.left];
	      cost = e0.cost+Math.abs(fdx+jdx)+Math.abs(fdy)+Math.abs(jumpdy)+1;
	      if (cost < e1.cost) {
		e1.action = PlanEntry.JUMP;
		e1.cost = cost;
		e1.next = e0;
		e1.arg = new Point(fx-vx, fy);
		queue.push(new QueueItem(e1, start));
	      }
	    }
	  }
	}
      }
      if (start != null) {
	// A* search.
	queue.sortOn("prio", Array.NUMERIC | Array.DESCENDING);
      }
      n--;
    }

    return n;
  }

  // getLandingPoint
  public static function getLandingPoint(map:TileMap, pos:Point, 
					 cb:Rectangle, 
					 velocity:Point, gravity:int,
					 maxdt:int=40):Point
  {
    var y0:int = Math.floor(pos.y / map.tilesize);
    for (var dt:int = 0; dt < maxdt; dt++) {
      var x:int = Math.floor((pos.x+velocity.x*dt) / map.tilesize);
      var y1:int = Math.floor((pos.y + dt*(dt+1)/2 * gravity) / map.tilesize);
      for (var y:int = y0; y <= y1; y++) {
	if (map.hasTile(x+cb.left, y+cb.bottom, 
			x+cb.right, y+cb.bottom, 
			Tile.isstoppable)) return null;
	if (map.hasTile(x+cb.left, y+cb.bottom+1, 
			x+cb.right, y+cb.bottom+1, 
			Tile.isstoppable)) {
	  return new Point(x, y);
	}
      }
      y0 = y1;
    }
    return null;
  }

}

} // package

import flash.geom.Point;
import flash.geom.Rectangle;

class QueueItem
{
  public var entry:PlanEntry;
  public var prio:int;
  
  public function QueueItem(entry:PlanEntry, start:Point=null)
  {
    this.entry = entry;
    this.prio = ((start == null)? 0 :
		 Math.abs(start.x-entry.p.x)+Math.abs(start.y-entry.p.y));
  }
}
