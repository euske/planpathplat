package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;

//  PlanAction
//
public class PlanAction extends EventDispatcher
{
  public static const NONE:String = "NONE";
  public static const WALK:String = "WALK";
  public static const FALL:String = "FALL";
  public static const CLIMB:String = "CLIMB";
  public static const JUMP:String = "JUMP";

  public var p:Point;
  public var type:String;
  public var cost:int;

  public var next:PlanAction;
  public var mid:Point;

  private var _actor:Actor;
  private var _jumped:Boolean;

  public function PlanAction(p:Point, type:String, cost:int)
  {
    this.p = p;
    this.type = type;
    this.cost = cost;
  }

  public override function toString():String
  {
    return ("<PlanAction: ("+p.x+","+p.y+") type="+type+", cost="+cost+">");
  }

  // begin
  public function begin(actor:Actor):void
  {
    Main.log(actor, "begin", this);
    _jumped = false;
  }

  // end
  public function end(actor:Actor):void
  {
    Main.log(actor, "end  ", this);
  }

  // update
  public function update(tilemap:TileMap, actor:Actor):Boolean
  {
    var cur:Point = tilemap.getCoordsByPoint(actor.pos);
    var dst:Point = next.p;
    var p:Point, path:Array;

    // Get a micro-level (greedy) plan.
    switch (type) {
    case WALK:
    case CLIMB:
      p = tilemap.getTilePoint(dst.x, dst.y);
      dispatchEvent(new PlanActionMoveToEvent(p));
      break;
	
    case FALL:
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isobstacle, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
	dispatchEvent(new PlanActionMoveToEvent(p));
      }
      break;
	  
    case JUMP:
      if (!_jumped) {
	if (!actor.isLanded() || actor.isGrabbing() ||
	    !hasClearance(tilemap, actor, cur.x, mid.y)) {
	  // not landed, grabbing something, or has no clearance.
	  p = tilemap.getTilePoint(cur.x, cur.y);
	  dispatchEvent(new PlanActionMoveToEvent(p));
	} else {
	  _jumped = true;
	  dispatchEvent(new PlanActionJumpEvent());
	}
      }
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isstoppable, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
	dispatchEvent(new PlanActionMoveToEvent(p));
      }
      break;
    }

    // finish the action if it reaches a temporary goal.
    return cur.equals(dst);
  }

  private function hasClearance(tilemap:TileMap, actor:Actor, x:int, y:int):Boolean
  {
    var r:Rectangle = tilemap.getTileRect(x+actor.tilebounds.left, 
					  y+actor.tilebounds.top, 
					  actor.tilebounds.width+1, 
					  actor.tilebounds.height+1);
    return (!tilemap.hasTileByRect(actor.bounds.union(r), Tile.isstoppable));
  }
}

} // package
