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

  private var _map:Object;

  // PlanMap(tilemap, goal, bounds)
  public function PlanMap(tilemap:TileMap, goal:Point, bounds:Rectangle)
  {
    this.tilemap = tilemap;
    this.goal = goal;
    this.bounds = bounds;
    _map = new Object();
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
  public function getAction(x:int, y:int, context:String=null):PlanAction
  {
    return _map[PlanAction.getKey(x, y, context)];
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
    
    var queue:Array = new Array();
    addQueue(queue, start, new PlanAction(goal));
    while (0 < n && 0 < queue.length) {
      var cost:int;
      var q:QueueItem = queue.pop();
      var a0:PlanAction = q.action;
      var p:Point = a0.p;
      var context:String = a0.context;
      if (start != null && start.equals(p)) break;
      if (tilemap.hasTile(p.x+cb.left, p.y+cb.top, 
			  p.x+cb.right, p.y+cb.bottom, 
			  Tile.isobstacle)) continue;
      if (context == null &&
	  !tilemap.hasTile(p.x+cb.left, p.y+cb.bottom+1, 
			   p.x+cb.right, p.y+cb.bottom+1, 
			   Tile.isstoppable)) continue;
      // assert(bounds.left <= p.x && p.x <= bounds.right);
      // assert(bounds.top <= p.y && p.y <= bounds.bottom);

      // try climbing down.
      if (context == null &&
	  bounds.top <= p.y-1 &&
	  tilemap.hasTile(p.x+cb.left, p.y+cb.bottom,
			  p.y+cb.right, p.y+cb.bottom,
			  Tile.isgrabbable)) {
	cost = a0.cost+1;
	addQueue(queue, start, 
		 new PlanAction(new Point(p.x, p.y-1), null,
				PlanAction.CLIMB, cost, a0));
      }
      // try climbing up.
      if (context == null &&
	  p.y+1 <= bounds.bottom &&
	  tilemap.hasTile(p.x+cb.left, p.y+cb.top+1,
			  p.x+cb.right, p.y+cb.bottom+1,
			  Tile.isgrabbable)) {
	cost = a0.cost+1;
	addQueue(queue, start, 
		 new PlanAction(new Point(p.x, p.y+1), null,
				PlanAction.CLIMB, cost, a0));
      }

      // for left and right.
      for (var vx:int = -1; vx <= +1; vx += 2) {
	var bx0:int = (0 < vx)? cb.left : cb.right;
	var bx1:int = (0 < vx)? cb.right : cb.left;

	// try walking.
	var wx:int = p.x-vx;
	if (context == null &&
	    bounds.left <= wx && wx <= bounds.right &&
	    tilemap.hasTile(wx+cb.left, p.y+cb.bottom+1,
			    wx+cb.right, p.y+cb.bottom+1,
			    Tile.isstoppable)) {
	  cost = a0.cost+1;
	  addQueue(queue, start, 
		   new PlanAction(new Point(wx, p.y), null,
				  PlanAction.WALK, cost, a0));
	}

	// try falling.
	if (context == null) {
	  for (var fdx:int = 0; fdx <= falldx; fdx++) {
	    var fx:int = p.x-vx*fdx;
	    if (fx < bounds.left || bounds.right < fx) break;
	    // fdt: time for falling.
	    var fdt:int = Math.ceil(tilemap.tilesize*fdx/speed);
	    // fdy: amount of falling.
	    var fdy:int = Math.ceil(fdt*(fdt+1)/2 * gravity / tilemap.tilesize);
	    for (; fdy <= falldy; fdy++) {
	      var fy:int = p.y-fdy;
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
	      cost = a0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	      if (0 < fdx &&
		  tilemap.hasTile(fx+cb.left, fy+cb.bottom+1, 
				  fx+cb.right, fy+cb.bottom+1, 
				  Tile.isstoppable)) {
		addQueue(queue, start, 
			 new PlanAction(new Point(fx, fy), null,
					PlanAction.FALL, cost, a0));
	      }
	      if (!tilemap.hasTile(fx+bx0, fy+cb.top, 
				   p.x+bx1, p.y+cb.bottom,
				   Tile.isstoppable)) {
		addQueue(queue, start, 
			 new PlanAction(new Point(fx, fy), PlanAction.JUMP,
					PlanAction.FALL, cost, a0));
	      }
	    }
	  }
	}

	// try jumping.
	if (context == PlanAction.JUMP) {
	  for (var jdx:int = 1; jdx <= madx; jdx++) {
	    // adt: time for ascending.
	    var adt:int = Math.floor(jdx*tilemap.tilesize/speed);
	    // ady: minimal ascend.
	    var ady:int = Math.floor((jumpspeed*adt - adt*(adt+1)/2 * gravity) / 
				     tilemap.tilesize);
	    for (var jdy:int = ady; jdy <= mady; jdy++) {
	      // (jx,jy): original position.
	      var jx:int = p.x-vx*jdx;
	      if (jx < bounds.left || bounds.right < jx) break;
	      var jy:int = p.y+jdy;
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
	      if (tilemap.hasTile(jx+bx0, p.y-1+cb.bottom, 
				  p.x+bx1, p.y-1+cb.top, 
				  Tile.isstoppable)) break;
	      if (tilemap.hasTile(jx+bx0, jy+cb.bottom, 
				  p.x+bx1-vx, p.y+cb.top, 
				  Tile.isstoppable)) break;
	      if (!tilemap.hasTile(jx+cb.left, jy+cb.bottom+1, 
				   jx+cb.right, jy+cb.bottom+1, 
				   Tile.isstoppable)) continue;
	      cost = a0.cost+Math.abs(jdx)+Math.abs(jdy)+1;
	      addQueue(queue, start, 
		       new PlanAction(new Point(jx, jy), null,
				      PlanAction.JUMP, cost, a0.next, p));
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

  // addQueue
  private function addQueue(queue:Array, start:Point, a1:PlanAction):void
  {
    var a0:PlanAction = _map[a1.key];
    if (a0 == null || a1.cost < a0.cost) {
      _map[a1.key] = a1;
      var dist:int = ((start == null)? 0 :
		      Math.abs(start.x-a1.p.x)+Math.abs(start.y-a1.p.y));
      queue.push(new QueueItem(a1, dist));
    }
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
  
  public function QueueItem(action:PlanAction, prio:int=0)
  {
    this.action = action;
    this.prio = prio;
  }
}
