package {

import flash.display.Shape;
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Point;
import flash.ui.Keyboard;

//  GameScreen
//
public class GameScreen extends Screen
{
  public static const NAME:String = "GameScreen";
  
  // Tile image:
  [Embed(source="../assets/tiles.png", mimeType="image/png")]
  private static const TilesImageCls:Class;
  private static const tilesimage:Bitmap = new TilesImageCls();

  // Map image:
  [Embed(source="../assets/map.png", mimeType="image/png")]
  private static const MapImageCls:Class;
  private static const mapimage:Bitmap = new MapImageCls();
  
  /// Game-related functions

  private var scene:Scene;
  private var player:Player;

  private function findSpot(i:int):Point
  {
    var tilemap:TileMap = scene.tilemap;
    var a:Array = tilemap.scanTile(0, 0, tilemap.width, tilemap.height, 
				   (function (b:int):Boolean { return b == i; }));
    return a[0];
  }

  public function GameScreen(width:int, height:int)
  {
    var tilesize:int = 32;
    var tilemap:TileMap = new TileMap(mapimage.bitmapData, tilesize);
    scene = new Scene(width, height, tilemap, tilesimage.bitmapData);
    addChild(scene);

    var p:Point;
    p = findSpot(Tile.PLAYER);
    player = new Player(scene);
    player.pos = tilemap.getTilePoint(p.x, p.y);
    player.bounds = tilemap.getTileRect(p.x, p.y-3+1, 1, 3);
    player.skin = createSkin(tilesize*1, tilesize*3, 0x44ff44);
    scene.add(player);

    var enemy1:Person = new Person(scene);
    p = findSpot(Tile.ENEMY1);
    enemy1.pos = tilemap.getTilePoint(p.x, p.y);
    enemy1.bounds = tilemap.getTileRect(p.x, p.y-3+1, 2, 3);
    enemy1.skin = createSkin(tilesize*2, tilesize*3, 0xff44ff);
    enemy1.target = player;
    enemy1.visualizer = new PlanVisualizer(scene);
    scene.add(enemy1);
    addChild(enemy1.visualizer);

    var enemy2:Person = new Person(scene);
    p = findSpot(Tile.ENEMY2);
    enemy2.pos = tilemap.getTilePoint(p.x, p.y);
    enemy2.bounds = tilemap.getTileRect(p.x, p.y-2+1, 1, 2);
    enemy2.skin = createSkin(tilesize*1, tilesize*2, 0x44ffff);
    enemy2.target = player;
    enemy2.visualizer = new PlanVisualizer(scene);
    scene.add(enemy2);
    addChild(enemy2.visualizer);
  }

  // open()
  public override function open():void
  {
  }

  // close()
  public override function close():void
  {
  }

  // update()
  public override function update():void
  {
    scene.update();
    scene.setCenter(player.pos, 100, 100);
    scene.paint();
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case 65:			// A
    case 72:			// H
      player.dir.x = -1;
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      player.dir.x = +1;
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      player.dir.y = -1;
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      player.dir.y = +1;
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      player.jump();
      break;

    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case Keyboard.RIGHT:
    case 65:			// A
    case 68:			// D
    case 72:			// H
    case 76:			// L
      player.dir.x = 0;
      break;

    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      player.dir.y = 0;
      break;
    }
  }

  // createSkin(w, h, color)
  public static function createSkin(w:int, h:int, color:uint):Shape
  {
    var shape:Shape = new Shape();
    shape.graphics.beginFill(color);
    shape.graphics.drawRect(0, 0, w, h);
    shape.graphics.endFill();
    return shape;
  }
}

} // package
