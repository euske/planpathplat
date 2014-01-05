package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;

//  Person
//
public class Person extends Actor
{
  public var visualizer:PlanVisualizer;

  private var _target:Actor;
  private var _runner:PlanActionRunner;

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
    _runner = null;
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
    if (goal == null) return;

    // adjust the goal position when it cannot fit.
    var obstacle:RangeMap = tilemap.getRangeMap(Tile.isObstacle);
    for (var dx:int = tilebounds.left; dx <= tilebounds.right; dx++) {
      if (!obstacle.hasTile(goal.x-dx+tilebounds.left, goal.y+tilebounds.top,
			    goal.x-dx+tilebounds.right, goal.y+tilebounds.bottom)) {
	goal.x -= dx;
	break;
      }
    }

    // make a plan.
    if (_runner == null) {
      var bounds:Rectangle = scene.getCenteredBounds(goal, 10);
      var plan:PlanMap = new PlanMap(tilemap, goal, bounds,
				     tilebounds, speed, jumpspeed, gravity);
      if (0 < plan.fillPlan(tilemap.getCoordsByPoint(pos))) {
	// start following a plan.
	_runner = new PlanActionRunner(plan, this);
	_runner.addEventListener(PlanActionJumpEvent.JUMP, onActionJump);
	_runner.addEventListener(PlanActionMoveToEvent.MOVETO, onActionMoveTo);
	Main.log("begin", _runner);
	// display the current plan.
	if (visualizer != null) {
	  visualizer.update(plan, tilemap.getCoordsByPoint(pos));
	}
      }
    }

    // follow a plan.
    if (_runner != null) {
      // end following a plan.
      if (!_runner.update(goal)) {
	Main.log("end  ", _runner);
	_runner.removeEventListener(PlanActionJumpEvent.JUMP, onActionJump);
	_runner.removeEventListener(PlanActionMoveToEvent.MOVETO, onActionMoveTo);
	_runner = null;
      }
    }
  }

  private function onActionJump(e:PlanActionJumpEvent):void
  {
    jump();
  }
  private function onActionMoveTo(e:PlanActionMoveToEvent):void
  {
    moveToward(e.p);
  }

}

} // package
