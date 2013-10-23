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

    var v:Point = new Point(0, 0);
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
      var mid:Point = _action.mid;
      var dst:Point = _action.next.p;
      var dstpos:Point = tilemap.getTilePoint(dst.x, dst.y);
      var r:Rectangle;
      //Main.log(" dst="+dst+", "+dstpos);
      //Main.log(" pos="+pos+", landed="+isLanded()+", jumpable="+isJumpable());

      // Get a micro-level (greedy) plan.
      switch (_action.action) {
      case PlanEntry.WALK:
	v = moveToward(dstpos);
	break;
	  
      case PlanEntry.CLIMB:
	v = moveToward(dstpos);
	break;
	  
      case PlanEntry.FALL:
	if (isLanded()) {
	  v = moveToward(dstpos);
	} else {
	  if (isReachableTo(dst)) {
	    v = moveToward(dstpos);
	  }
	}
	break;
	  
      case PlanEntry.JUMP:
	if (!_jumping) {
	  if (isLanded() && isReachableTo(mid)) {
	    jump();
	    _jumping = true;
	  } else {
	    v = moveToward(curpos);
	  }
	} else {
	  if (isReachableTo(dst)) {
	    v = moveToward(dstpos);
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
    move(v);

    if (visualizer != null) {
      visualizer.plan = _plan;
    }
  }

  private function moveToward(p:Point):Point
  {
    var v:Point = new Point(speed * Utils.clamp(-1, (p.x-pos.x), +1),
			    speed * Utils.clamp(-1, (p.y-pos.y), +1));
    if (isLanded()) {
      if (isMovable(v.x, v.y)) {
	return v;
      } else if (isMovable(0, v.y)) {
	return new Point(0, v.y);
      }
    } else {
      if (isMovable(v.x, 0)) {
	return new Point(v.x, 0);
      }
    }
    return new Point(0, 0);
  }

  private function isReachableTo(p:Point):Boolean
  {
    var r:Rectangle = bounds.union(tilemap.getTileRect(p.x, p.y));
    return (!tilemap.hasTileByRect(r, Tile.isstoppable));
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
