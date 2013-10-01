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
  private var _entry:PlanEntry;
  private var _jumping:Boolean;
  private var _falling:Boolean;

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

  // update()
  public override function update():void
  {
    super.update();
    var vx:int, vy:int;
    var start:Point = tilemap.getCoordsByPoint(pos);
    var goal:Point = tilemap.getCoordsByPoint(_target.pos);

    // invalidate plan.
    if (_plan != null && !_plan.goal.equals(goal)) {
      _plan = null;
    }

    // make a plan.
    if (_plan == null) {
      if (_target.isLanded()) {
	var jumpdt:int = Math.floor(jumpspeed / gravity);
	var falldt:int = Math.floor(maxspeed / gravity);
	var plan:PlanMap = scene.createPlan(goal);
	if (0 < plan.fillPlan(tilebounds, 
			      jumpdt, falldt, speed, gravity,
			      start, 50)) {
	  _plan = plan;
	  if (visualizer != null) {
	    visualizer.plan = plan;
	  }
	}
      }
    }

    // follow a plan.
    if (_entry == null && _plan != null) {
      // Get a macro-level plan.
      var entry:PlanEntry = _plan.getEntry(start.x, start.y);
      if (entry != null && entry.next != null) {
	Main.log("entry="+entry);
	_entry = entry;
	_jumping = false;
	_falling = false;
      }
    }
    if (_entry != null) {
      var srcpos:Point = tilemap.getTilePoint(start.x, start.y);
      var dst:Point = _entry.next.p;
      var dstpos:Point = tilemap.getTilePoint(dst.x, dst.y);
      Main.log("action="+_entry.action+", start="+start+", dst="+dst);

      // Get a micro-level (greedy) plan.
      switch (_entry.action) {
      case PlanEntry.WALK:
	vx = Utils.clamp(-1, (dstpos.x-pos.x), +1);
	if (!isMovable(vx*speed, 0)) {
	  vx = 0;
	  vy = Utils.clamp(-1, (dstpos.y-pos.y), +1);
	}
	break;
	  
      case PlanEntry.CLIMB:
	vy = Utils.clamp(-1, (dstpos.y-pos.y), +1);
	if (!isMovable(0, vy*speed)) {
	  vx = Utils.clamp(-1, (dstpos.x-pos.x), +1);
	  vy = 0;
	}
	break;
	  
      case PlanEntry.FALL:
	if (!_falling) {
	  Main.log("srcpos="+srcpos+", pos="+pos);
	  if (srcpos.equals(pos)) {
	    _falling = true;
	  } else {
	    vx = Utils.clamp(-1, (srcpos.x-pos.x), +1);
	    vy = Utils.clamp(-1, (srcpos.y-pos.y), +1);
	  }
	} else if (isLanded() ||
		   !tilemap.hasTile(start.x, start.y, dst.x, dst.y, Tile.isstoppable)) {
	  vx = Utils.clamp(-1, (dstpos.x-pos.x), +1);
	}
	break;
	  
      case PlanEntry.JUMP:
	if (!_jumping) {
	  if (srcpos.equals(pos)) {
	    jump();
	    _jumping = true;
	  } else {
	    vx = Utils.clamp(-1, (srcpos.x-pos.x), +1);
	    vy = Utils.clamp(-1, (srcpos.y-pos.y), +1);
	  }
	} else {
	  var mid:Point = (isJumping())? Point(_entry.arg) : dst;
	  if (!tilemap.hasTile(start.x, start.y, mid.x, mid.y, Tile.isstoppable)) {
	    var midpos:Point = tilemap.getTilePoint(mid.x, mid.y);
	    vx = Utils.clamp(-1, (midpos.x-pos.x), +1);
	  }
	}
	break;
      }

      if (_entry.next.p.equals(start)) {
	_entry = null;
      }
    }
    move(new Point(vx*speed, vy*speed));
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
