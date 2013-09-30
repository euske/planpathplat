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

  private function get tilewindow():Rectangle
  {
    return tilemap.tilewindow;
  }
  private function get tilesize():int
  {
    return tilemap.tilesize;
  }

  private function drawRect(color:uint, p:Point, size:int):void
  {
    graphics.lineStyle(0, color);
    graphics.drawRect((p.x-tilewindow.left+0.5)*tilesize-size/2, 
		      (p.y-tilewindow.top+0.5)*tilesize-size/2, 
		      size, size);
  }

  private function drawLine(color:uint, src:Point, dst:Point):void
  {
    graphics.lineStyle(0, color);
    graphics.moveTo((src.x-tilewindow.left+0.5)*tilesize,
		    (src.y-tilewindow.top+0.5)*tilesize);
    graphics.lineTo((dst.x-tilewindow.left+0.5)*tilesize,
		    (dst.y-tilewindow.top+0.5)*tilesize);
  }

  public function repaint():void
  {
    graphics.clear();
    if (plan == null) return;

    for (var y:int = 0; y < tilewindow.height; y++) {
      for (var x:int = 0; x <= tilewindow.width; x++) {
	var e:PlanEntry = plan.getEntry(tilewindow.left+x, 
					tilewindow.top+y);
	if (e == null) continue;
	var p:Point = e.p;
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanEntry.WALK:	// white
	  drawRect(0xffffff, p, tilesize);
	  break;
	case PlanEntry.CLIMB:	// green
	  drawRect(0x00ff00, p, tilesize);
	  break;
	case PlanEntry.FALL:	// blue
	  drawRect(0x0000ff, p, tilesize);
	  if (e.next != null) {
	    drawLine(0x0000ff, p, e.next.p);
	  }
	  break;
	case PlanEntry.JUMP:	// magenta
	  drawRect(0xff00ff, p, tilesize);
	  if (e.arg != null && e.next != null) {
	    var pm:Point = Point(e.arg);
	    drawLine(0xff00ff, p, pm);
	    drawLine(0xff00ff, pm, e.next.p);
	  }
	  break;
	}
      }
    }
    drawRect(0x00ff00, plan.dst, tilesize-4);
    if (plan.src != null) {
      drawRect(0xffffff, plan.src, tilesize-4);
    }

    this.x = tilemap.x;
    this.y = tilemap.y;
  }
}

} // package
