package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Person
//
public class Person extends Actor
{
  public var visualizer:PlanVisualizer;

  private var _target:Actor;
  private var _plan:PlanMap;
  private var _action:PlanAction;
  private var _jumping:Boolean;

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
  }

  // target
  public function get target():Actor
  {
    return _target;
  }
  public function set target(value:Actor):void
  {
    _target = value;
    _plan = null;
    _action = null;
    _jumping = false;
  }

  // update()
  public override function update():void
  {
    super.update();
    fall();

    var goal:Point = ((_target.isLanded())?
		      tilemap.getCoordsByPoint(_target.pos) :
		      PlanMap.getLandingPoint(tilemap, _target.pos,
					      _target.tilebounds,
					      _target.velocity, _target.gravity));
    // invalidate plan.
    if (_plan != null && !_plan.isValid(goal)) {
      _plan = null;
    }

    // make a plan.
    var cur:Point = tilemap.getCoordsByPoint(pos);
    if (_plan == null && _action == null && goal != null) {
      var jumpdt:int = Math.floor(jumpspeed / gravity);
      var plan:PlanMap = scene.createPlan(goal, 10);
      if (0 < plan.addPlan(tilebounds, 
			   jumpdt, speed, gravity,
			   cur)) {
	_plan = plan;
      }
    }

    // follow a plan.
    if (_plan != null && _action == null) {
      // Get a macro-level plan.
      var action:PlanAction = _plan.getAction(cur.x, cur.y);
      if (action != null && action.next != null) {
	_action = action;
	_jumping = false;
	Main.log(this, "begin", _action, _plan.goal);
      }
    }

    // do an action.
    if (_action != null) {
      var dst:Point = _action.next.p;
      var path:Array;

      // Get a micro-level (greedy) plan.
      switch (_action.action) {
      case PlanAction.WALK:
      case PlanAction.CLIMB:
	moveToward(tilemap.getTilePoint(dst.x, dst.y));
	break;
	  
      case PlanAction.FALL:
	{
	  path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
					Tile.isobstacle, tilebounds);
	  if (0 < path.length) {
	    moveToward(tilemap.getTilePoint(path[0].x, path[0].y));
	  }
	}
	break;
	  
      case PlanAction.JUMP:
	if (!_jumping) {
	  var y:int = _action.mid.y;
	  if (isLanded() && !isGrabbing() && 
	      hasClearance(new Point(cur.x, y))) {
	    jump();
	    _jumping = true;
	  } else {
	    moveToward(tilemap.getTilePoint(cur.x, cur.y));
	  }
	} else {
	  path = tilemap.findSimplePath(dst.x, dst.y, cur.x, cur.y, 
					Tile.isstoppable, tilebounds);
	  if (0 < path.length) {
	    moveToward(tilemap.getTilePoint(path[0].x, path[0].y));
	  }
	}
	break;
      }

      // finishing an action.
      if (cur.equals(dst)) {
	Main.log(this, "end  ", _action);
	_action = null;
      }

    }

    if (visualizer != null) {
      visualizer.plan = _plan;
    }
  }
  
  // repaint()
  public override function repaint():void
  {
    super.repaint();
    if (visualizer != null) {
      visualizer.repaint();
    }
  }

  private function hasClearance(p:Point):Boolean
  {
    var r:Rectangle = tilemap.getTileRect(p.x+tilebounds.left, p.y+tilebounds.top, 
					  tilebounds.width+1, tilebounds.height+1);
    return !tilemap.hasTileByRect(bounds.union(r), Tile.isstoppable);
  }

}

} // package
