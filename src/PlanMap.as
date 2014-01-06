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
  public var cb:Rectangle;
  public var speed:int;
  public var jumpspeed:int;
  public var gravity:int;

  private var _map:Object;
  private var _madx:int;
  private var _mady:int;

  // PlanMap(tilemap, goal, bounds)
  public function PlanMap(tilemap:TileMap, goal:Point, 
			  bounds:Rectangle, cb:Rectangle,
			  speed:int, jumpspeed:int, gravity:int)
  {
    this.tilemap = tilemap;
    this.goal = goal;
    this.bounds = bounds;
    this.cb = cb;
    this.speed = speed;
    this.jumpspeed = jumpspeed;
    this.gravity = gravity;
    _map = new Object();
    // madt: maximum amount of time for ascending.
    var madt:int = Math.floor(jumpspeed / gravity);
    // madx: maximum horizontal distance while ascending.
    _madx = Math.floor(madt*speed / tilemap.tilesize);
    // mady: maximum vertical distance while ascending.
    _mady = Math.floor(ascend(jumpspeed, madt, gravity) / tilemap.tilesize);
  }

  private static function ascend(v0:Number, dt:Number, g:Number):Number
  {
    return (v0*dt - (dt-1)*dt*g/2);
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

  // getAllActions()
  public function getAllActions():Array
  {
    var a:Array = new Array();
    for each (var action:PlanAction in _map) {
      a.push(action);
    }
    return a;
  }

  // fillPlan(plan, b)
  public function fillPlan(start:Point=null, n:int=1000,
			   falldx:int=10, falldy:int=20):Boolean
  {
    var obstacle:RangeMap = tilemap.getRangeMap(Tile.isObstacle);
    var stoppable:RangeMap = tilemap.getRangeMap(Tile.isStoppable);
    var grabbable:RangeMap = tilemap.getRangeMap(Tile.isGrabbable);

    if (start != null &&
	!stoppable.hasTile(start.x+cb.left, start.y+cb.bottom+1, 
			   start.x+cb.right, start.y+cb.bottom+1)) return false;
    
    var queue:Array = new Array();
    addQueue(queue, start, new PlanAction(goal));
    while (0 < n && 0 < queue.length) {
      var cost:int;
      var q:QueueItem = queue.pop();
      var a0:PlanAction = q.action;
      var p:Point = a0.p;
      var context:String = a0.context;
      if (start != null && start.equals(p)) return true;
      if (obstacle.hasTile(p.x+cb.left, p.y+cb.top, 
			   p.x+cb.right, p.y+cb.bottom)) continue;
      if (context == null &&
	  !stoppable.hasTile(p.x+cb.left, p.y+cb.bottom+1, 
			     p.x+cb.right, p.y+cb.bottom+1)) continue;
      // assert(bounds.left <= p.x && p.x <= bounds.right);
      // assert(bounds.top <= p.y && p.y <= bounds.bottom);

      // try climbing down.
      if (context == null &&
	  bounds.top <= p.y-1 &&
	  grabbable.hasTile(p.x+cb.left, p.y+cb.bottom,
			    p.y+cb.right, p.y+cb.bottom)) {
	cost = a0.cost+1;
	addQueue(queue, start, 
		 new PlanAction(new Point(p.x, p.y-1), null,
				PlanAction.CLIMB, cost, a0));
      }
      // try climbing up.
      if (context == null &&
	  p.y+1 <= bounds.bottom &&
	  grabbable.hasTile(p.x+cb.left, p.y+cb.top+1,
			    p.x+cb.right, p.y+cb.bottom+1)) {
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
	    !obstacle.hasTile(wx+cb.left, p.y+cb.top,
			      wx+cb.right, p.y+cb.bottom) &&
	    stoppable.hasTile(wx+cb.left, p.y+cb.bottom+1,
			      wx+cb.right, p.y+cb.bottom+1)) {
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
	    var fdt:int = Math.floor(tilemap.tilesize*fdx/speed);
	    // fdy: amount of falling.
	    var fdy:int = Math.ceil(-ascend(0, fdt, gravity) / tilemap.tilesize);
	    for (; fdy <= falldy; fdy++) {
	      var fy:int = p.y-fdy;
	      if (fy < bounds.top || bounds.bottom < fy) break;
	      //  +--+....  [vx = +1]
	      //  |  |....
	      //  +-X+.... (fx,fy) original position.
	      // ##.......
	      //   ...+--+
	      //   ...|  |
	      //   ...+-X+ (p.x,p.y)
	      //     ######
	      if (stoppable.hasTile(fx+bx0+vx, fy+cb.top, 
				    p.x+bx1, p.y+cb.bottom)) break;
	      if (obstacle.hasTile(fx+cb.left, fy+cb.top,
				   fx+cb.right, fy+cb.bottom)) continue;
	      cost = a0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	      if (0 < fdx &&
		  stoppable.hasTile(fx+cb.left, fy+cb.bottom+1, 
				    fx+cb.right, fy+cb.bottom+1)) {
		// normal fall.
		addQueue(queue, start, 
			 new PlanAction(new Point(fx, fy), null,
					PlanAction.FALL, cost, a0));
	      }
	      if (!stoppable.hasTile(fx+bx0, fy+cb.top, 
				     p.x+bx1, p.y+cb.bottom)) {
		// fall after jump.
		addQueue(queue, start, 
			 new PlanAction(new Point(fx, fy), PlanAction.FALL,
					PlanAction.FALL, cost, a0));
	      }
	    }
	  }
	}

	// try jumping.
	if (context == PlanAction.FALL) {
	  for (var jdx:int = 1; jdx <= _madx; jdx++) {
	    // adt: time for ascending.
	    var adt:int = Math.floor(jdx*tilemap.tilesize/speed);
	    // ady: minimal ascend.
	    var ady:int = Math.floor(ascend(jumpspeed, adt, gravity) / tilemap.tilesize);
	    for (var jdy:int = ady; jdy <= _mady; jdy++) {
	      // (jx,jy): original position.
	      var jx:int = p.x-vx*jdx;
	      if (jx < bounds.left || bounds.right < jx) break;
	      var jy:int = p.y+jdy;
	      if (jy < bounds.top || bounds.bottom < jy) break;
	      //  ....+--+  [vx = +1]
	      //  ....|  |
	      //  ....+-X+ (p.x,p.y) tip point
	      //  .......
	      //  +--+...
	      //  |  |...
	      //  +-X+... (jx,jy) original position.
	      // ######
	      if (stoppable.hasTile(jx+bx0, jy+cb.bottom, 
				    p.x+bx1-vx, p.y+cb.top)) break;
	      if (!stoppable.hasTile(jx+cb.left, jy+cb.bottom+1, 
				     jx+cb.right, jy+cb.bottom+1)) continue;
	      // extra care is needed not to allow the following case:
	      //      .#
	      //    +--+
	      //    |  |  (this is impossible!)
	      //    +-X+
	      //       #
	      if (tilemap.isTile(p.x+bx1, p.y+cb.top-1, Tile.isObstacle) &&
		  tilemap.isTile(p.x+bx1, p.y+cb.bottom+1, Tile.isObstacle) &&
		  !tilemap.isTile(p.x+bx1-vx, p.y+cb.top-1, Tile.isObstacle)) continue;
	      cost = a0.cost+Math.abs(jdx)+Math.abs(jdy)+1;
	      addQueue(queue, start, 
		       new PlanAction(new Point(jx, jy), null,
				      PlanAction.JUMP, cost, a0));
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

    return false;
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
    var stoppable:RangeMap = tilemap.getRangeMap(Tile.isStoppable);
    var y0:int = Math.floor(pos.y / tilemap.tilesize);
    for (var dt:int = 0; dt < maxdt; dt++) {
      var x:int = Math.floor((pos.x+velocity.x*dt) / tilemap.tilesize);
      if (x < 0 || tilemap.width <= x) continue;
      var y1:int = Math.ceil((pos.y - ascend(0, dt, gravity)) / tilemap.tilesize);
      for (var y:int = y0; y <= y1; y++) {
	if (y < 0 || tilemap.height <= y) continue;
	if (stoppable.hasTile(x+cb.left, y+cb.bottom, 
			      x+cb.right, y+cb.bottom)) return null;
	if (stoppable.hasTile(x+cb.left, y+cb.bottom+1, 
			      x+cb.right, y+cb.bottom+1)) {
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
