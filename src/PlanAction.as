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

  public var tilemap:TileMap;
  public var p:Point;
  public var action:String;
  public var cost:int;

  public var next:PlanAction;
  public var mid:Point;

  private var _actor:Actor;
  private var _finished:Boolean;
  private var _jumped:Boolean;

  public function PlanAction(tilemap:TileMap, p:Point, action:String, cost:int)
  {
    this.tilemap = tilemap;
    this.p = p;
    this.action = action;
    this.cost = cost;
  }

  public override function toString():String
  {
    return ("<PlanAction: ("+p.x+","+p.y+") action="+action+", cost="+cost+">");
  }

  // isFinished
  public function get isFinished():Boolean
  {
    return _finished;
  }

  // begin
  public function begin(actor:Actor):void
  {
    Main.log(actor, "begin", this);
    _finished = false;
    _jumped = false;
  }

  // end
  public function end(actor:Actor):void
  {
    Main.log(actor, "end  ", this);
  }

  // update
  public function update(actor:Actor):Point
  {
    var p:Point = null;
    var cur:Point = tilemap.getCoordsByPoint(actor.pos);
    var dst:Point = next.p;
    var path:Array;

    // Get a micro-level (greedy) plan.
    switch (action) {
    case WALK:
    case CLIMB:
      p = tilemap.getTilePoint(dst.x, dst.y);
	
    case FALL:
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isobstacle, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
      }
      break;
	  
    case JUMP:
      if (!_jumped) {
	if (!actor.isLanded() || actor.isGrabbing() ||
	    !hasClearance(actor, cur.x, mid.y)) {
	  // not landed, grabbing something, or has no clearance.
	  p = tilemap.getTilePoint(cur.x, cur.y);
	} else {
	  _jumped = true;
	  dispatchEvent(new Event(JUMP));
	}
      }
      path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
				    Tile.isstoppable, actor.tilebounds);
      if (0 < path.length) {
	p = tilemap.getTilePoint(path[0].x, path[0].y);
      }
      break;
    }

    // finishing an action.
    if (cur.equals(dst)) {
      _finished = true;
    }

    return p;
  }

  private function hasClearance(actor:Actor, x:int, y:int):Boolean
  {
    var r:Rectangle = tilemap.getTileRect(x+actor.tilebounds.left, 
					  y+actor.tilebounds.top, 
					  actor.tilebounds.width+1, 
					  actor.tilebounds.height+1);
    return (!tilemap.hasTileByRect(actor.bounds.union(r), Tile.isstoppable));
  }
}

} // package
