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
  public var scene:Scene;

  private var _skin:DisplayObject;

  protected var _scene:Scene;

  private var _vg:int = 0;
  private var _phase:Number = 0;
  private var _jumping:Boolean;

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
    pos = new Point(0, 0);
    _scene = scene;
  }

  // skin
  public virtual function get skin():DisplayObject
  {
    return _skin;
  }
  public virtual function set skin(value:DisplayObject):void
  {
    if (_skin != null) {
      removeChild(_skin);
    }
    _skin = value;
    if (_skin != null) {
      addChild(_skin);
      _skin.x = -Math.floor(_scene.tilemap.tilesize/2);
      _skin.y = -Math.floor(_skin.height)+Math.floor(_scene.tilemap.tilesize/2);
    }
  }

  // tilebounds
  public virtual function get tilebounds():Rectangle
  {
    var w:int = _skin.width/_scene.tilemap.tilesize;
    var h:int = _skin.height/_scene.tilemap.tilesize;
    return new Rectangle(0, -(h-1), w-1, h-1);
  }

  public function setSkin(w:int, h:int, color:uint):void
  {
    var shape:Shape = new Shape();
    shape.graphics.beginFill(color);
    shape.graphics.drawRect(0, 0, w, h);
    skin = shape;
  }

  // bounds
  public virtual function get bounds():Rectangle
  {
    return new Rectangle(pos.x+_skin.x, pos.y+_skin.y, _skin.width, _skin.height);
  }
  public virtual function set bounds(value:Rectangle):void
  {
    pos.x = Math.floor((value.left+value.right)/2);
    pos.y = Math.floor((value.top+value.bottom)/2);
  }

  // move()
  public function move(v0:Point):void
  {
    if (isGrabbing()) {
      // climing a ladder.
      var vl:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x, v0.y, Tile.isobstacle);
      pos = Utils.movePoint(pos, vl.x, vl.y);
      _vg = 0;
    } else {
      // falling.
      var vf:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x, _vg, Tile.isstoppable);
      pos = Utils.movePoint(pos, vf.x, vf.y);
      // moving (in air).
      var vdx:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x-vf.x, 0, Tile.isobstacle);
      pos = Utils.movePoint(pos, vdx.x, vdx.y);
      var vdy:Point;
      if (0 < v0.y) {
	// start climing down.
	vdy = _scene.tilemap.getCollisionByRect(bounds, 0, _vg-vf.y+v0.y, Tile.isobstacle);
      } else {
	// falling (cont'd).
	vdy = _scene.tilemap.getCollisionByRect(bounds, 0, _vg-vf.y, Tile.isstoppable);
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
    var p:Point = _scene.translatePoint(pos);
    this.x = p.x;
    this.y = p.y;
  }

  // jump()
  public function jump():void
  {
    if (isLanded()) {
      _vg = -jumpspeed;
      _jumping = true;
    }
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return _scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isstoppable);
  }
  
  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return _scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }
  
  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    var r:Rectangle = Utils.moveRect(bounds, dx, dy);
    return (!_scene.tilemap.hasTileByRect(r, Tile.isobstacle));
  }
  
  // hasUpperLadderNearby()
  public function hasUpperLadderNearby():int
  {
    var r:Rectangle = bounds;
    var r0:Rectangle = Utils.moveRect(r, -r.width, 0);
    var r1:Rectangle = Utils.moveRect(r, +r.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(r0, Tile.isgrabbable);
    var h1:Boolean = _scene.tilemap.hasTileByRect(r1, Tile.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }
  }

  // hasLowerLadderNearby()
  public function hasLowerLadderNearby():int
  {
    var r:Rectangle = bounds;
    var rb:Rectangle = new Rectangle(r.x, r.bottom, r.width, 1);
    var rb0:Rectangle = Utils.moveRect(rb, -rb.width, 0);
    var rb1:Rectangle = Utils.moveRect(rb, +rb.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(rb0, Tile.isgrabbable);
    var h1:Boolean = _scene.tilemap.hasTileByRect(rb1, Tile.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }    
  }

  // hasHoleNearby()
  public function hasHoleNearby():int
  {
    var r:Rectangle = bounds;
    var rb:Rectangle = new Rectangle(r.x, r.bottom, r.width, 1);
    var rb0:Rectangle = Utils.moveRect(rb, -rb.width, 0);
    var rb1:Rectangle = Utils.moveRect(rb, +rb.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(rb0, Tile.isnone);
    var h1:Boolean = _scene.tilemap.hasTileByRect(rb1, Tile.isnone);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }    
  }
}

} // package
