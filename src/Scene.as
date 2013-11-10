package {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Scene
// 
public class Scene extends Sprite
{
  public var tilemap:TileMap;

  private var _window:Rectangle;
  private var _mapsize:Point;
  private var _actors:Array;

  // Scene(width, height, tilemap)
  public function Scene(width:int, height:int, tilemap:TileMap)
  {
    this.tilemap = tilemap;
    _window = new Rectangle(0, 0, width, height);
    _mapsize = new Point(tilemap.mapwidth*tilemap.tilesize,
			 tilemap.mapheight*tilemap.tilesize);
    _actors = new Array();
    addChild(tilemap);
  }

  // add(actor)
  public function add(actor:Actor):void
  {
    _actors.push(actor);
    addChild(actor.skin);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    _actors.remove(actor);
    removeChild(actor.skin);
  }

  // update()
  public function update():void
  {
    for each (var actor:Actor in _actors) {
      actor.update();
    }
  }

  // repaint()
  public function repaint():void
  {
    for each (var actor:Actor in _actors) {
      var p:Point = translatePoint(actor.pos);
      actor.skin.x = p.x+actor.frame.x;
      actor.skin.y = p.y+actor.frame.y;
    }
    tilemap.repaint(_window);
  }

  // setCenter(p)
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (p.x-hmargin < _window.x) {
      _window.x = p.x-hmargin;
    } else if (_window.x+_window.width < p.x+hmargin) {
      _window.x = p.x+hmargin-_window.width;
    }
    if (p.y-vmargin < _window.y) {
      _window.y = p.y-vmargin;
    } else if (_window.y+_window.height < p.y+vmargin) {
      _window.y = p.y+vmargin-_window.height;
    }
    
    // Adjust the window position to fit the world.
    if (_window.x < 0) {
      _window.x = 0;
    } else if (_mapsize.x < _window.x+_window.width) {
      _window.x = _mapsize.x-_window.width;
    }
    if (_window.y < 0) {
      _window.y = 0;
    } else if (_mapsize.y < _window.y+_window.height) {
      _window.y = _mapsize.y-_window.height;
    }
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-_window.x, p.y-_window.y);
  }

  // createPlan(center)
  public function createPlan(center:Point, margin:int=0):PlanMap
  {
    var x0:int = Math.floor(_window.left/tilemap.tilesize);
    x0 = Math.max(x0-margin, 0);
    var y0:int = Math.floor(_window.top/tilemap.tilesize);
    y0 = Math.max(y0-margin, 0);
    var x1:int = Math.ceil(_window.right/tilemap.tilesize);
    x1 = Math.min(x1+margin, tilemap.mapwidth-1);
    var y1:int = Math.ceil(_window.bottom/tilemap.tilesize);
    y1 = Math.min(y1+margin, tilemap.mapheight-1);
    var bounds:Rectangle = new Rectangle(x0, y0, x1-x0, y1-y0);
    return new PlanMap(tilemap, center, bounds);
  }
}

} // package
