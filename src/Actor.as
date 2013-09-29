package {

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor extends Sprite
{
  public var pos:Point;

  private var _skin:DisplayObject;
  private var _scene:Scene;

  private var _vg:int = 0;
  private var _phase:Number = 0;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpspeed:int = 24;
  public const maxspeed:int = 24;

  public static var isstoppable:Function = 
    (function (b:int):Boolean { return b != 0; });
  public static var isobstacle:Function =
    (function (b:int):Boolean { return b < 0 || b == 1; });
  public static var isgrabbable:Function =
    (function (b:int):Boolean { return b < 0 || b == 2; });
  public static var isnone:Function = 
    (function (b:int):Boolean { return b == 0; });
  
  // Actor(scene)
  public function Actor(scene:Scene)
  {
    _scene = scene;
    pos = new Point(0, 0);
  }

  // scene
  public function get scene():Scene
  {
    return _scene;
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
      _skin.x = -Math.floor(scene.tilemap.tilesize/2);
      _skin.y = -Math.floor(_skin.height)+Math.floor(scene.tilemap.tilesize/2);
    }
  }

  // tilebounds
  public function get tilebounds():Rectangle
  {
    var w:int = skin.width/scene.tilemap.tilesize;
    var h:int = skin.height/scene.tilemap.tilesize;
    return new Rectangle(0, -(h-1), w-1, h-1);
  }

  // bounds
  public function get bounds():Rectangle
  {
    return new Rectangle(pos.x+skin.x, pos.y+skin.y, skin.width, skin.height);
  }
  public function set bounds(value:Rectangle):void
  {
    pos.x = Math.floor((value.left+value.right)/2);
    pos.y = Math.floor((value.top+value.bottom)/2);
  }

  // getMovedRect(dx, dy)
  public function getMovedRect(dx:int, dy:int):Rectangle
  {
    return Utils.moveRect(bounds, dx, dy);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isstoppable);
  }

  // isJumping()
  public function isJumping():Boolean
  {
    return (_vg < 0);
  }
  
  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }

  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    return (!scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isobstacle));
  }

  // move()
  public virtual function move(v0:Point):void
  {
    if (isGrabbing()) {
      // climing a ladder.
      var vl:Point = scene.tilemap.getCollisionByRect(bounds, v0.x, v0.y, Tile.isobstacle);
      pos = Utils.movePoint(pos, vl.x, vl.y);
      _vg = 0;
    } else {
      // falling.
      var vf:Point = scene.tilemap.getCollisionByRect(bounds, v0.x, _vg, Tile.isstoppable);
      pos = Utils.movePoint(pos, vf.x, vf.y);
      // moving (in air).
      var vdx:Point = scene.tilemap.getCollisionByRect(bounds, v0.x-vf.x, 0, Tile.isobstacle);
      pos = Utils.movePoint(pos, vdx.x, vdx.y);
      var vdy:Point;
      if (0 < v0.y) {
	// start climing down.
	vdy = scene.tilemap.getCollisionByRect(bounds, 0, _vg-vf.y+v0.y, Tile.isobstacle);
      } else {
	// falling (cont'd).
	vdy = scene.tilemap.getCollisionByRect(bounds, 0, _vg-vf.y, Tile.isstoppable);
      }
      pos = Utils.movePoint(pos, vdy.x, vdy.y);
      _vg = Math.min(vf.y+vdx.y+vdy.y+gravity, maxspeed);
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

  // jump()
  public virtual function jump():void
  {
    if (isLanded()) {
      _vg = -jumpspeed;
    }
  }

  // createSkin(w, h, color)
  public function createSkin(w:int, h:int, color:uint):void
  {
    var shape:Shape = new Shape();
    shape.graphics.beginFill(color);
    shape.graphics.drawRect(0, 0, w, h);
    skin = shape;
  }
}

} // package
