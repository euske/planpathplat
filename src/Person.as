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
  private var _plan:PlanMap;
  private var _action:PlanAction;

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
    if (_plan == null && _action == null && goal != null) {
      var jumpdt:int = Math.floor(jumpspeed / gravity);
      var plan:PlanMap = scene.createPlan(goal, 10);
      if (0 < plan.addPlan(tilebounds, 
			   jumpdt, speed, gravity,
			   tilemap.getCoordsByPoint(pos))) {
	_plan = plan;
      }
    }

    // follow a plan.
    if (_plan != null && _action == null) {
      // Get a macro-level plan.
      var cur:Point = tilemap.getCoordsByPoint(pos);
      var action:PlanAction = _plan.getAction(cur.x, cur.y);
      if (action != null && action.next != null) {
	_action = action;
	_action.addEventListener(PlanAction.JUMP, onActionJump);
	_action.begin(this);
      }
    }

    // perform an action.
    if (_action != null) {
      var p:Point = _action.update(this);
      if (p != null) {
	moveToward(p);
      }
      if (_action.isFinished) {
	// finishing an action.
	_action.end(this);
	_action.removeEventListener(PlanAction.JUMP, onActionJump);
	_action = null;
      }
    }

    // display the current plan.
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

  private function onActionJump(e:Event):void
  {
    jump();
  }

}

} // package
