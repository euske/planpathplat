package {

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor extends Sprite
{
  public var pos:Point;

  private var _skin:DisplayObject;
  private var _scene:Scene;
  private var _velocity:Point;
  private var _phase:Number = 0;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpspeed:int = 24;
  public const maxspeed:int = 24;

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

  // skin
  public function get skin():DisplayObject
  {
    return _skin;
  }
  public function set skin(value:DisplayObject):void
  {
    if (_skin != null) {
      removeChild(_skin);
    }
    _skin = value;
    if (_skin != null) {
      addChild(_skin);
      _skin.x = -Math.floor(tilemap.tilesize/2);
      _skin.y = -Math.floor(_skin.height)+Math.floor(tilemap.tilesize/2);
    }
  }

  // bounds
  public function get bounds():Rectangle
  {
    return getBoundsAt(pos);
  }
  public function set bounds(value:Rectangle):void
  {
    pos.x = Math.floor((value.left+value.right)/2);
    pos.y = Math.floor((value.top+value.bottom)/2);
  }

  // tilebounds
  public function get tilebounds():Rectangle
  {
    var w:int = skin.width/tilemap.tilesize;
    var h:int = skin.height/tilemap.tilesize;
    return new Rectangle(0, -(h-1), w-1, h-1);
  }

  // velocity
  public function get velocity():Point
  {
    return _velocity;
  }
  
  // getMovedBounds(dx, dy)
  public function getMovedBounds(dx:int, dy:int):Rectangle
  {
    return Utils.moveRect(bounds, dx, dy);
  }

  // getBoundsAt(p)
  public function getBoundsAt(p:Point):Rectangle
  {
    return new Rectangle(p.x+skin.x, p.y+skin.y, skin.width, skin.height);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return (0 <= _velocity.y && 
	    tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isstoppable));
  }

  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }

  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    return (!tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isobstacle));
  }

  // update()
  public virtual function update():void
  {
  }

  // repaint()
  public virtual function repaint():void
  {
    var p:Point = scene.translatePoint(pos);
    this.x = p.x;
    this.y = p.y;
  }

  // jump()
  public function jump():void
  {
    if (isLanded() && !isGrabbing()) {
      _velocity.y = -jumpspeed;
    }
  }

  // fall()
  public function fall():void
  {
    if (!isGrabbing() && !isLanded()) {
      var v:Point;
      // falling (in x and y).
      v = tilemap.getCollisionByRect(bounds, _velocity.x, _velocity.y, 
				     Tile.isstoppable);
      // falling (in x).
      v.x = tilemap.getCollisionByRect(bounds, _velocity.x, v.y, 
				       Tile.isobstacle).x;
      // falling (in y).
      v.y = tilemap.getCollisionByRect(bounds, v.x, _velocity.y, 
				       Tile.isstoppable).y;
      pos = Utils.movePoint(pos, v.x, v.y);
      _velocity = new Point(v.x, Math.min(v.y+gravity, maxspeed));
    }
  }

  // move(v)
  public function move(v:Point):void
  {
    if (isGrabbing()) {
      // climing a ladder.
      v = tilemap.getCollisionByRect(bounds, v.x, v.y, 
				     Tile.isobstacle);
      pos = Utils.movePoint(pos, v.x, v.y);
      _velocity = new Point(0, 0);
    } else if (isLanded()) {
      // moving.
      v = tilemap.getCollisionByRect(bounds, v.x, Math.max(0, v.y), 
				     Tile.isobstacle);
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
    var v:Point = new Point(speed * Utils.clamp(-1, (p.x-pos.x), +1),
			    speed * Utils.clamp(-1, (p.y-pos.y), +1));
    if (isLanded() || isGrabbing()) {
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

  // createSkin(w, h, color)
  public function createSkin(w:int, h:int, color:uint):void
  {
    var shape:Shape = new Shape();
    shape.graphics.beginFill(color);
    shape.graphics.drawRect(0, 0, w, h);
    shape.graphics.endFill();
    skin = shape;
  }
}

} // package
