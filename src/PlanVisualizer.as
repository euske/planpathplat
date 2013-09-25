package {

import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public static var main:PlanVisualizer;

  public var plan:PlanMap;
  public var tilemap:TileMap;

  public function PlanVisualizer(tilemap:TileMap)
  {
    super();
    main = this;
    this.tilemap = tilemap;
  }

  public function repaint():void
  {
    graphics.clear();
    if (plan == null) return;

    var ts:int = tilemap.tilesize;
    var tw:Rectangle = tilemap.tilewindow;
    for (var y:int = 0; y < tw.height; y++) {
      for (var x:int = 0; x <= tw.width; x++) {
	var e:PlanEntry = plan.getEntry(tw.left+x, tw.top+y);
	if (e == null) continue;
	var p:Point = e.p;
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanEntry.WALK:
	  c = 0xffffff;		// white
	  break;
	case PlanEntry.FALL:
	  c = 0x0000ff;		// blue
	  break;
	case PlanEntry.CLIMB:	// green
	  c = 0x00ff00;
	  break;
	case PlanEntry.JUMP:	// magenta
	  c = 0xff00ff;
	  break;
	default:
	  continue;
	}
	graphics.lineStyle(0, c);
	graphics.drawRect((p.x-tw.left)*ts, (p.y-tw.top)*ts, ts, ts);
	graphics.lineStyle(0, 0xffff00);
	if (e.next != null) {
	  var pn:Point = e.next.p;
	  graphics.moveTo((p.x-tw.left)*ts+ts/2, (p.y-tw.top)*ts+ts/2);
	  graphics.lineTo((pn.x-tw.left)*ts+ts/2, (pn.y-tw.top)*ts+ts/2);
	}
      }
    }
    graphics.lineStyle(0, 0x00ff00);
    graphics.drawRect((plan.dst.x-tw.left)*ts+2, (plan.dst.y-tw.top)*ts+2, ts-4, ts-4);
    if (plan.src != null) {
      graphics.lineStyle(0, 0xffffff);
      graphics.drawRect((plan.src.x-tw.left)*ts+2, (plan.src.y-tw.top)*ts+2, ts-4, ts-4);
    }

    this.x = tilemap.x;
    this.y = tilemap.y;
  }
}

} // package
