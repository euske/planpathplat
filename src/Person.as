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

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
  }

  // target
  public function set target(value:Actor):void
  {
    _target = value;
    _plan = null;
  }

  private function moveToward(p:Point):Point
  {
    var v:Point = new Point(speed * Utils.clamp(-1, (p.x-pos.x), +1),
			    speed * Utils.clamp(-1, (p.y-pos.y), +1));
    if (isMovable(v.x, v.y)) {
      return v;
    } else if (isMovable(v.x, 0)) {
      return new Point(v.x, 0);
    } else if (isMovable(0, v.y)) {
      return new Point(0, v.y);
    } else {
      return new Point(0, 0);
    }
  }

  // update()
  public override function update():void
  {
    super.update();
    var v:Point = new Point(0, 0);
    var start:Point = tilemap.getCoordsByPoint(pos);
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
    if (_plan == null && goal != null) {
      var jumpdt:int = Math.floor(jumpspeed / gravity);
      var plan:PlanMap = scene.createPlan(goal);
      if (0 < plan.addPlan(tilebounds, 
			    jumpdt, speed, gravity,
			    start)) {
	_plan = plan;
      }
    }

    // follow a plan.
    if (_action == null && _plan != null) {
      // Get a macro-level plan.
      var action:PlanEntry = _plan.getEntry(start.x, start.y);
      if (action != null && action.next != null) {
	Main.log("action="+action);
	_action = action;
      }
    }
    if (_action != null) {
      var startpos:Point = tilemap.getTilePoint(start.x, start.y);
      var dst:Point = _action.next.p;
      var dstpos:Point = tilemap.getTilePoint(dst.x, dst.y);
      //Main.log(" start="+start+", "+startpos);
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
	} else if (!tilemap.hasTile(start.x, start.y, dst.x, dst.y, Tile.isstoppable)) {
	  v.x = speed * Utils.clamp(-1, (dstpos.x-pos.x), +1);
	}
	break;
	  
      case PlanEntry.JUMP:
	var mid:Point = Point(_action.arg);
	if (_action.p.equals(start)) {
	  if (isJumpable()) {
	    jump();
	  } else {
	    v = moveToward(startpos);
	  }
	} else {
	  var tmp:Point = (velocity.y < 0)? mid : dst;
	  if (!tilemap.hasTile(start.x, start.y, tmp.x, tmp.y, Tile.isstoppable)) {
	    var tmppos:Point = tilemap.getTilePoint(tmp.x, tmp.y);
	    v.x = speed * Utils.clamp(-1, (tmppos.x-pos.x), +1);
	  }
	}
	break;
      }

      // finishing an action.
      if (_action.next.p.equals(start)) {
	//Main.log(" finished.");
	_action = null;
      }

    }
    move(v);

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
