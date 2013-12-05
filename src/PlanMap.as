package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var tilemap:TileMap;
  public var goal:Point;
  public var bounds:Rectangle;

  private var _a:Array;

  // PlanMap(tilemap, goal, bounds)
  public function PlanMap(tilemap:TileMap, goal:Point, bounds:Rectangle)
  {
    this.tilemap = tilemap;
    this.goal = goal;
    this.bounds = bounds;
    _a = new Array(bounds.height+1);
    var inf:int = (bounds.width+bounds.height+1)*2;
    for (var y:int = bounds.top; y <= bounds.bottom; y++) {
      var b:Array = new Array(bounds.width+1);
      for (var x:int = bounds.left; x <= bounds.right; x++) {
	var p:Point = new Point(x, y);
	b[x-bounds.left] = new PlanAction(p, PlanAction.NONE, inf);
      }
      _a[y-bounds.top] = b;
    }
  }

  public function toString():String
  {
    return ("<PlanMap ("+bounds.left+","+bounds.top+")-("+
	    bounds.right+","+bounds.bottom+")>");
  }

  // isValid(pos)
  public function isValid(p:Point):Boolean
  {
    return (p != null && goal.equals(p));
  }

  // getAction(x, y)
  public function getAction(x:int, y:int):PlanAction
  {
    if (x < bounds.left || bounds.right < x ||
	y < bounds.top || bounds.bottom < y) return null;
    return _a[y-bounds.top][x-bounds.left];
  }

  // addPlan(plan, b)
  public function addPlan(cb:Rectangle, 
			  speed:int, jumpspeed:int, gravity:int,
			  start:Point=null, n:int=1000,
			  falldx:int=10, falldy:int=20):int
  {
    // madt: maximum amount of time for ascending.
    var madt:int = Math.floor(jumpspeed / gravity);
    // madx: maximum horizontal distance while ascending.
    var madx:int = Math.floor(madt*speed / tilemap.tilesize);
    // mady: maximum vertical distance while ascending.
    var mady:int = Math.floor((jumpspeed*madt - madt*(madt+1)/2*gravity) / tilemap.tilesize);

    if (start != null &&
	!tilemap.hasTile(start.x+cb.left, start.y+cb.bottom+1, 
			 start.x+cb.right, start.y+cb.bottom+1, 
			 Tile.isstoppable)) return 0;

    if (goal.x < bounds.left || bounds.right < goal.x ||
	goal.y < bounds.top || bounds.bottom < goal.y) return 0;
    
    var e1:PlanAction = _a[goal.y-bounds.top][goal.x-bounds.left];
    e1.cost = 0;
    var queue:Array = [ new QueueItem(e1) ];
    while (0 < n && 0 < queue.length) {
      var cost:int;
      var q:QueueItem = queue.pop();
      var e0:PlanAction = q.action;
      var p:Point = e0.p;
      if (start != null && start.equals(p)) break;
      if (tilemap.hasTile(p.x+cb.left, p.y+cb.top, 
			  p.x+cb.right, p.y+cb.bottom, 
			  Tile.isobstacle)) continue;
      if (!tilemap.hasTile(p.x+cb.left, p.y+cb.bottom+1, 
			   p.x+cb.right, p.y+cb.bottom+1, 
			   Tile.isstoppable)) continue;
      // assert(bounds.left <= p.x && p.x <= bounds.right);
      // assert(bounds.top <= p.y && p.y <= bounds.bottom);

      // try climbing down.
      if (bounds.top <= p.y-1 &&
	  tilemap.hasTile(p.x+cb.left, p.y+cb.bottom,
			  p.y+cb.right, p.y+cb.bottom,
			  Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top-1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.type = PlanAction.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(new QueueItem(e1, start));
	}
      }
      // try climbing up.
      if (p.y+1 <= bounds.bottom &&
	  tilemap.hasTile(p.x+cb.left, p.y+cb.top+1,
			  p.x+cb.right, p.y+cb.bottom+1,
			  Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top+1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.type = PlanAction.CLIMB;
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
	    tilemap.hasTile(wx+cb.left, p.y+cb.bottom+1,
			    wx+cb.right, p.y+cb.bottom+1,
			    Tile.isstoppable)) {
	  e1 = _a[p.y-bounds.top][wx-bounds.left];
	  cost = e0.cost+1;
	  if (cost < e1.cost) {
	    e1.type = PlanAction.WALK;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(new QueueItem(e1, start));
	  }
	}

	// try falling.
	for (fdx = 1; fdx <= falldx; fdx++) {
	  fx = p.x-vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) break;
	  fdt = Math.ceil(tilemap.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / tilemap.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) break;
	    //  +--+....  [vx = +1]
	    //  |  |....
	    //  +-X+.... (fx,fy) original position.
	    // ==.......
	    //   ...+--+
	    //   ...|  |
	    //   ...+-X+ (p.x,p.y)
	    //     ======
	    if (tilemap.hasTile(fx+bx0+vx, fy+cb.top, 
				p.x+bx1, p.y+cb.bottom,
				Tile.isstoppable)) break;
	    if (!tilemap.hasTile(fx+cb.left, fy+cb.bottom+1, 
				 fx+cb.right, fy+cb.bottom+1, 
				 Tile.isstoppable)) continue;
	    e1 = _a[fy-bounds.top][fx-bounds.left];
	    cost = e0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	    if (cost < e1.cost) {
	      e1.type = PlanAction.FALL;
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
	  // fdt: time for falling.
	  fdt = Math.ceil(tilemap.tilesize*fdx/speed);
	  // fdy: amount of falling.
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / tilemap.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    // (fx,fy): tip position.
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) break;
	    //  +--+.....  [vx = +1]
	    //  |  |.....
	    //  +-X+..... (fx,fy) midpoint
	    //  .........
	    //  .....+--+
	    //  .....|  |
	    //  .....+-X+ (p.x,p.y)
	    //      ======
	    if (tilemap.hasTile(fx+bx0, fy+cb.top, 
				p.x+bx1, p.y+cb.bottom, 
				Tile.isstoppable)) break;
	    for (var jdx:int = 1; jdx <= madx; jdx++) {
	      // adt: time for ascending.
	      var adt:int = Math.floor(jdx*tilemap.tilesize/speed);
	      // ady: minimal ascend.
	      var ady:int = Math.floor((jumpspeed*adt - adt*(adt+1)/2 * gravity) / 
				       tilemap.tilesize);
	      for (var jdy:int = ady; jdy <= mady; jdy++) {
		// (jx,jy): original position.
		var jx:int = fx-vx*jdx;
		if (jx < bounds.left || bounds.right < jx) break;
		var jy:int = fy+jdy;
		if (jy < bounds.top || bounds.bottom < jy) break;
		//  ........ (extra clearance is needed)
		//  ....+--+  [vx = +1]
		//  ....|  |
		//  ....+-X+ (fx,fy) midpoint
		//  .......
		//  +--+...
		//  |  |...
		//  +-X+... (jx,jy) original position.
		// ======
		if (tilemap.hasTile(jx+bx0, fy-1+cb.bottom, 
				    fx+bx1, fy-1+cb.top, 
				    Tile.isstoppable)) break;
		if (tilemap.hasTile(jx+bx0, jy+cb.bottom, 
				    fx+bx1-vx, fy+cb.top, 
				    Tile.isstoppable)) break;
		if (!tilemap.hasTile(jx+cb.left, jy+cb.bottom+1, 
				     jx+cb.right, jy+cb.bottom+1, 
				     Tile.isstoppable)) continue;
		e1 = _a[jy-bounds.top][jx-bounds.left];
		cost = e0.cost+Math.abs(fdx+jdx)+Math.abs(fdy)+Math.abs(jdy)+1;
		if (cost < e1.cost) {
		  e1.type = PlanAction.JUMP;
		  e1.cost = cost;
		  e1.next = e0;
		  e1.mid = new Point(fx, fy);
		  queue.push(new QueueItem(e1, start));
		}
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
  public static function getLandingPoint(tilemap:TileMap, pos:Point, 
					 cb:Rectangle, 
					 velocity:Point, gravity:int,
					 maxdt:int=20):Point
  {
    var y0:int = Math.floor(pos.y / tilemap.tilesize);
    for (var dt:int = 0; dt < maxdt; dt++) {
      var x:int = Math.floor((pos.x+velocity.x*dt) / tilemap.tilesize);
      if (x < 0 || tilemap.width <= x) continue;
      var y1:int = Math.ceil((pos.y + dt*(dt+1)/2 * gravity) / tilemap.tilesize);
      for (var y:int = y0; y <= y1; y++) {
	if (y < 0 || tilemap.height <= y) continue;
	if (tilemap.hasTile(x+cb.left, y+cb.bottom, 
			    x+cb.right, y+cb.bottom, 
			    Tile.isstoppable)) return null;
	if (tilemap.hasTile(x+cb.left, y+cb.bottom+1, 
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
  public var action:PlanAction;
  public var prio:int;
  
  public function QueueItem(action:PlanAction, start:Point=null)
  {
    this.action = action;
    this.prio = ((start == null)? 0 :
		 Math.abs(start.x-action.p.x)+Math.abs(start.y-action.p.y));
  }
}
