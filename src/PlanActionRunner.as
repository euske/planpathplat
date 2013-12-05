package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;

//  PlanActionRunner
//
public class PlanActionRunner extends EventDispatcher
{
  public var tilemap:TileMap;
  public var actor:Actor;
  public var action:PlanAction;

  private var _jumped:Boolean;
  private var _finished:Boolean;

  public function PlanActionRunner(tilemap:TileMap, actor:Actor, action:PlanAction)
  {
    this.tilemap = tilemap;
    this.actor = actor;
    this.action = action;
  }

  public override function toString():String
  {
    return ("<PlanActionRunner: actor="+actor+", action="+action+">");
  }

  // isFinished
  public function get isFinished():Boolean
  {
    return _finished;
  }

  // update
  public function update():void
  {
    var cur:Point = tilemap.getCoordsByPoint(actor.pos);
    var dst:Point = action.next.p;
    var p:Point, path:Array;

    // Get a micro-level (greedy) plan.
    switch (action.type) {
    case PlanAction.WALK:
    case PlanAction.CLIMB:
      p = tilemap.getTilePoint(dst.x, dst.y);
      dispatchEvent(new PlanActionMoveToEvent(p));
      break;
	
    case PlanAction.FALL:
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isobstacle, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
	dispatchEvent(new PlanActionMoveToEvent(p));
      }
      break;
	  
    case PlanAction.JUMP:
      if (!_jumped) {
	if (!actor.isLanded() || actor.isGrabbing() ||
	    !hasClearance(cur.x, action.mid.y)) {
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
    _finished = cur.equals(dst);
  }

  private function hasClearance(x:int, y:int):Boolean
  {
    var r:Rectangle = tilemap.getTileRect(x+actor.tilebounds.left, 
					  y+actor.tilebounds.top, 
					  actor.tilebounds.width+1, 
					  actor.tilebounds.height+1);
    return (!tilemap.hasTileByRect(actor.bounds.union(r), Tile.isstoppable));
  }
}

} // package
