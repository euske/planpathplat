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
  private var _jumped:Boolean;

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
    var src:Point = scene.tilemap.getCoordsByPoint(pos);
    var dst:Point = scene.tilemap.getCoordsByPoint(_target.pos);

    // invalidate plan.
    if (_plan != null && !_plan.dst.equals(dst)) {
      _plan = null;
    }

    // make a plan.
    if (_plan == null) {
      if (_target.isLanded()) {
	var jumpdt:int = Math.floor(jumpspeed / gravity);
	var falldt:int = Math.floor(maxspeed / gravity);
	var plan:PlanMap = scene.createPlan(dst);
	if (0 < plan.fillPlan(src, tilebounds, 50,
			      jumpdt, falldt, speed, gravity)) {
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
      var entry:PlanEntry = _plan.getEntry(src.x, src.y);
      if (entry != null && entry.next != null) {
	Main.log("entry="+entry);
	_entry = entry;
	_jumped = false;
      }
    }
    if (_entry != null) {
      var next:Point = _entry.next.p;
      var nextpos:Point = scene.tilemap.getTilePoint(next.x, next.y);
      // Get a micro-level (greedy) plan.
      switch (_entry.action) {
      case PlanEntry.WALK:
	vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	if (!isMovable(vx*speed, 0)) {
	  vx = 0;
	  vy = Utils.clamp(-1, (nextpos.y-pos.y), +1);
	}
	break;
	  
      case PlanEntry.CLIMB:
	vy = Utils.clamp(-1, (nextpos.y-pos.y), +1);
	if (!isMovable(0, vy*speed)) {
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  vy = 0;
	}
	break;
	  
      case PlanEntry.FALL:
	if (src.equals(_entry.p) ||
	    !scene.tilemap.hasTile(src.x, src.y, next.x, next.y, Tile.isstoppable)) {
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	}
	break;
	  
      case PlanEntry.JUMP:
	if (!_jumped) {
	  var cur:Point = scene.tilemap.getTilePoint(src.x, src.y);
	  vx = Utils.clamp(-1, (cur.x-pos.x), +1);
	  if (isLanded() && vx == 0) {
	    Main.log("jump");
	    jump();
	    _jumped = true;
	  }
	} else {
	  if (!scene.tilemap.hasTile(src.x, src.y, next.x, next.y, Tile.isstoppable)) {
	    vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  } else {
	    Main.log("blckc!");
	  }
	}
	break;
      }
      Main.log("action="+_entry.action+", src="+src+", next="+next);

      if (_entry.next.p.equals(src)) {
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
