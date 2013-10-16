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
  private var _vg:int = 0;
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
    return tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isstoppable);
  }

  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }

  // isJumpable()
  public function isJumpable():Boolean
  {
    return !tilemap.hasTileByRect(bounds, Tile.isstoppable);
  }

  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    return (!tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isobstacle));
  }

  // move()
  public virtual function move(v0:Point):void
  {
    var v:Point;
    if (isGrabbing()) {
      // climing a ladder.
      v = tilemap.getCollisionByRect(bounds, v0.x, v0.y, Tile.isobstacle);
      _velocity = new Point(v.x, 0);
    } else {
      // falling (in x and y).
      v = tilemap.getCollisionByRect(bounds, v0.x, _velocity.y, Tile.isstoppable);
      // falling (in x).
      v.x = tilemap.getCollisionByRect(bounds, v0.x, v.y, Tile.isstoppable).x;
      // falling (in y).
      v.y = tilemap.getCollisionByRect(bounds, v.x, _velocity.y, Tile.isstoppable).y;
      _velocity = new Point(v.x, Math.min(v.y+gravity, maxspeed));
      pos = Utils.movePoint(pos, v.x, v.y);
      // moving.
      v = tilemap.getCollisionByRect(bounds, v0.x-v.x, Math.max(0, v0.y), Tile.isobstacle);
    }
    pos = Utils.movePoint(pos, v.x, v.y);
  }

  // jump()
  public virtual function jump():void
  {
    if (isLanded()) {
      _velocity.y = -jumpspeed;
    }
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
