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

  private var _tilemap:TileMap;
  private var _action:PlanAction;

  public function PlanActionRunner(plan:PlanMap, actor:Actor)
  {
    this.plan = plan;
    this.actor = actor;
    _tilemap = plan.tilemap;
    var cur:Point = _tilemap.getCoordsByPoint(actor.pos);
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
  public function update(goal:Point):Boolean
  {
    if (_action != null && _action.next != null) {
      var valid:Boolean = plan.isValid(goal);
      var cur:Point = _tilemap.getCoordsByPoint(actor.pos);
      var dst:Point = _action.next.p;
      var p:Point, path:Array;

      // Get a micro-level (greedy) plan.
      switch (_action.type) {
      case PlanAction.WALK:
      case PlanAction.CLIMB:
	p = _tilemap.getTilePoint(dst.x, dst.y);
	dispatchEvent(new PlanActionMoveToEvent(p));
	if (cur.equals(dst)) {
	  _action = (valid)? _action.next : null;
	}
	break;
	
      case PlanAction.FALL:
	path = _tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				       Tile.isobstacle, actor.tilebounds);
	if (0 < path.length) {
	  p = _tilemap.getTilePoint(path[0].x, path[0].y);
	  dispatchEvent(new PlanActionMoveToEvent(p));
	}
	if (cur.equals(dst)) {
	  _action = (valid)? _action.next : null;
	}
	break;
	  
      case PlanAction.JUMP:
	if (actor.isLanded() && !actor.isGrabbing() &&
	    hasClearance(cur.x, dst.y)) {
	  dispatchEvent(new PlanActionJumpEvent());
	  _action = (valid)? _action.next : null;
	} else {
	  // not landed, grabbing something, or has no clearance.
	  p = _tilemap.getTilePoint(cur.x, cur.y);
	  dispatchEvent(new PlanActionMoveToEvent(p));
	}
	break;
      }
    }
    return (_action != null && _action.next != null);
  }

  private function hasClearance(x:int, y:int):Boolean
  {
    var r:Rectangle = _tilemap.getTileRect(x+actor.tilebounds.left, 
					   y+actor.tilebounds.top, 
					   actor.tilebounds.width+1, 
					   actor.tilebounds.height+1);
    return (!_tilemap.hasTileByRect(actor.bounds.union(r), Tile.isstoppable));
  }
}

} // package
