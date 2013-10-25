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
  private var _action:PlanEntry;
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

    var cur:Point = tilemap.getCoordsByPoint(pos);
    var curpos:Point = tilemap.getTilePoint(cur.x, cur.y);
    var goal:Point = ((_target.isLanded())?
		      tilemap.getCoordsByPoint(_target.pos) :
		      PlanMap.getLandingPoint(tilemap, _target.pos,
					      _target.tilebounds,
					      _target.velocity, _target.gravity));

    // invalidate plan.
    if (_plan != null) {
      if (goal == null || !_plan.goal.equals(goal)) {
	_plan = null;
      }
    }

    // make a plan.
    if (goal != null && _action == null && _plan == null) {
      var jumpdt:int = Math.floor(jumpspeed / gravity);
      var plan:PlanMap = scene.createPlan(goal);
      if (0 < plan.addPlan(tilebounds, 
			   jumpdt, speed, gravity,
			   cur)) {
	_plan = plan;
      }
    }

    // follow a plan.
    if (_plan != null && _action == null) {
      // Get a macro-level plan.
      var action:PlanEntry = _plan.getEntry(cur.x, cur.y);
      if (action != null && action.next != null) {
	_action = action;
	_jumping = false;
	Main.log(this+": begin: "+_action+" for "+_plan.goal);
      }
    }
    if (_action != null) {
      var dst:Point = _action.next.p;
      var dstpos:Point = tilemap.getTilePoint(dst.x, dst.y);
      var path:Array;
      //Main.log(" dst="+dst+", "+dstpos);
      //Main.log(" pos="+pos+", landed="+isLanded()+", jumpable="+isJumpable());

      // Get a micro-level (greedy) plan.
      switch (_action.action) {
      case PlanEntry.WALK:
      case PlanEntry.CLIMB:
	moveToward(dstpos);
	break;
	  
      case PlanEntry.FALL:
	{
	  path = tilemap.findPath(dst.x, dst.y, cur.x, cur.y, 
				  Tile.isstoppable, tilebounds);
	  if (0 < path.length) {
	    moveToward(tilemap.getTilePoint(path[0].x, path[0].y));
	  }
	}
	break;
	  
      case PlanEntry.JUMP:
	if (!_jumping) {
	  if (isLanded() && !isGrabbing()) {
	    jump();
	    _jumping = true;
	  } else {
	    moveToward(curpos);
	  }
	} else {
	  path = tilemap.findPath(dst.x, dst.y, cur.x, cur.y, 
				  Tile.isstoppable, tilebounds);
	  if (0 < path.length) {
	    moveToward(tilemap.getTilePoint(path[0].x, path[0].y));
	  }
	}
	break;
      }

      // finishing an action.
      if (_action.next.p.equals(cur)) {
	Main.log(this+": end: "+_action);
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

}

} // package
