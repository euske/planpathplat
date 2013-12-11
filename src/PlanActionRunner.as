package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;

//  PlanActionRunner
//
public class PlanActionRunner extends EventDispatcher
{
  public var plan:PlanMap;
  public var actor:Actor;

  private var _action:PlanAction;

  public function PlanActionRunner(plan:PlanMap, actor:Actor)
  {
    this.plan = plan;
    this.actor = actor;
    var cur:Point = plan.tilemap.getCoordsByPoint(actor.pos);
    _action = plan.getAction(cur.x, cur.y);
  }

  public override function toString():String
  {
    return ("<PlanActionRunner: actor="+actor+", action="+_action+">");
  }

  // isFinished
  public function get isFinished():Boolean
  {
    return (_action == null || _action.next == null);
  }

  // update
  public function update():void
  {
    var tilemap:TileMap = plan.tilemap;
    var cur:Point = tilemap.getCoordsByPoint(actor.pos);
    var dst:Point = _action.next.p;
    var p:Point, path:Array;

    // Get a micro-level (greedy) plan.
    switch (_action.type) {
    case PlanAction.WALK:
    case PlanAction.CLIMB:
      p = tilemap.getTilePoint(dst.x, dst.y);
      dispatchEvent(new PlanActionMoveToEvent(p));
      if (cur.equals(dst)) {
	_action = _action.next;
      }
      break;
	
    case PlanAction.FALL:
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isobstacle, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
	dispatchEvent(new PlanActionMoveToEvent(p));
      }
      if (cur.equals(dst)) {
	_action = _action.next;
      }
      break;
	  
    case PlanAction.JUMP:
      if (actor.isLanded() && !actor.isGrabbing() &&
	  hasClearance(cur.x, dst.y)) {
	dispatchEvent(new PlanActionJumpEvent());
	_action = _action.next;
      } else {
	// not landed, grabbing something, or has no clearance.
	p = tilemap.getTilePoint(cur.x, cur.y);
	dispatchEvent(new PlanActionMoveToEvent(p));
      }
      break;
    }

  }

  private function hasClearance(x:int, y:int):Boolean
  {
    var tilemap:TileMap = plan.tilemap;
    var r:Rectangle = tilemap.getTileRect(x+actor.tilebounds.left, 
					  y+actor.tilebounds.top, 
					  actor.tilebounds.width+1, 
					  actor.tilebounds.height+1);
    return (!tilemap.hasTileByRect(actor.bounds.union(r), Tile.isstoppable));
  }
}

} // package
