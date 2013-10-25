package {

import flash.display.Bitmap;
import flash.events.Event;
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

  public function GameScreen(width:int, height:int)
  {
    var tilesize:int = 32;
    var tilemap:TileMap = new TileMap(mapimage.bitmapData, tilesimage.bitmapData, tilesize);
    scene = new Scene(width, height, tilemap);
    addChild(scene);

    player = new Player(scene);
    player.createSkin(tilesize*1, tilesize*3, 0x44ff44);
    scene.add(player);

    var enemy1:Person = new Person(scene);
    enemy1.bounds = tilemap.getTileRect(6, 6);
    enemy1.createSkin(tilesize*2, tilesize*3, 0xff44ff);
    enemy1.target = player;
    enemy1.visualizer = new PlanVisualizer(tilemap);
    scene.add(enemy1)
    addChild(enemy1.visualizer);

    //var enemy2:Person = new Person(scene);
    //enemy2.bounds = tilemap.getTileRect(10, 9);
    //enemy2.createSkin(tilesize*1, tilesize*2, 0x44ffff);
    //enemy2.target = player;
    //enemy2.visualizer = new PlanVisualizer(tilemap);
    //scene.add(enemy2)
    //addChild(enemy2.visualizer);
  }

  // open()
  public override function open():void
  {
    player.bounds = scene.tilemap.getTileRect(3, 3);
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
    scene.repaint();
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
}

} // package
