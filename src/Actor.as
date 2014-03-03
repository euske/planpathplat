package {

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor
{
  public var pos:Point;
  public var frame:Rectangle;
  public var skin:DisplayObject;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpspeed:int = 24;
  public const maxspeed:int = 24;

  private var _scene:Scene;
  private var _velocity:Point;

  // Actor(scene)
  public function Actor(scene:Scene)
  {
    _scene = scene;
    _velocity = new Point(0, 0);
    pos = new Point(0, 0);
  }

  // scene
  public function get scene():Scene
  {
    return _scene;
  }

  // tilemap
  public function get tilemap():TileMap
  {
    return _scene.tilemap;
  }

  // velocity
  public function get velocity():Point
  {
    return _velocity;
  }
  
  // bounds
  public function get bounds():Rectangle
  {
    return new Rectangle(pos.x+frame.x, pos.y+frame.y, 
			 frame.width, frame.height);
  }
  public function set bounds(value:Rectangle):void
  {
    frame = new Rectangle(value.x-pos.x, value.y-pos.y,
			  value.width, value.height);
  }

  // tilebounds
  public function get tilebounds():Rectangle
  {
    var w:int = frame.width/tilemap.tilesize;
    var h:int = frame.height/tilemap.tilesize;
    return new Rectangle(0, -(h-1), w-1, h-1);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return (0 <= _velocity.y && 
	    tilemap.getRangeMap(Tile.isStoppable).hasCollisionByRect(bounds, 0, 1));
  }

  // isHolding()
  public function isHolding():Boolean
  {
    return tilemap.getRangeMap(Tile.isGrabbable).hasTileByRect(bounds);
  }

  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    return (!tilemap.getRangeMap(Tile.isObstacle).hasCollisionByRect(bounds, dx, dy));
  }

  // getMovedBounds(dx, dy)
  public function getMovedBounds(dx:int, dy:int):Rectangle
  {
    return Utils.moveRect(bounds, dx, dy);
  }

  // update()
  public virtual function update():void
  {
  }

  // jump()
  public function jump():void
  {
    if (isLanded() && !isHolding()) {
      _velocity.y = -jumpspeed;
    }
  }

  // fall()
  public function fall():void
  {
    if (!isHolding() && !isLanded()) {
      var v:Point;
      //var f:Function = (_velocity.y < 0)? Tile.isObstacle : Tile.isStoppable;
      var f:Function = Tile.isObstacle;
      // falling (in x and y).
      v = tilemap.getCollisionByRect(bounds, _velocity.x, _velocity.y, f);
      // falling (in x).
      v.x = tilemap.getCollisionByRect(bounds, _velocity.x, v.y, 
				       Tile.isObstacle).x;
      // falling (in y).
      v.y = tilemap.getCollisionByRect(bounds, v.x, _velocity.y, f).y;
      pos = Utils.movePoint(pos, v.x, v.y);
      _velocity = new Point(v.x, Math.min(v.y+gravity, maxspeed));
    }
  }

  // move(v)
  public function move(v:Point):void
  {
    if (isHolding()) {
      // climing a ladder.
      v = tilemap.getCollisionByRect(bounds, v.x, v.y, 
				     Tile.isObstacle);
      pos = Utils.movePoint(pos, v.x, v.y);
      _velocity = new Point(0, 0);
    } else if (isLanded()) {
      // moving.
      v = tilemap.getCollisionByRect(bounds, v.x, Math.max(0, v.y), 
				     Tile.isObstacle);
      pos = Utils.movePoint(pos, v.x, v.y);
      _velocity = new Point(0, 0);
    } else {
      // jumping/falling.
      _velocity = new Point(v.x, _velocity.y);
    }
  }

  // moveToward(p)
  public function moveToward(p:Point):void
  {
    var v:Point = new Point(Utils.clamp(-speed, (p.x-pos.x), +speed),
			    Utils.clamp(-speed, (p.y-pos.y), +speed));
    if (isLanded() || isHolding()) {
      if (isMovable(v.x, v.y)) {
	move(v);
      } else if (isMovable(0, v.y)) {
	move(new Point(0, v.y));
      } else if (isMovable(v.x, 0)) {
	move(new Point(v.x, 0));
      }
    } else {
      if (isMovable(v.x, 0)) {
	move(new Point(v.x, 0));
      }
    }
  }
}

} // package
