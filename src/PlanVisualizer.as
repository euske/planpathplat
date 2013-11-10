package {

import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public var plan:PlanMap;
  public var tilemap:TileMap;
  public var tilewindow:Rectangle = new Rectangle();

  public function PlanVisualizer(tilemap:TileMap)
  {
    super();
    this.tilemap = tilemap;
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
	var e:PlanAction = plan.getAction(tilewindow.left+x, 
					  tilewindow.top+y);
	if (e == null) continue;
	var p:Point = e.p;
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanAction.WALK:	// white
	  drawRect(0xffffff, p, tilesize);
	  break;
	case PlanAction.CLIMB:	// green
	  drawRect(0x00ff00, p, tilesize);
	  break;
	case PlanAction.FALL:	// blue
	  drawRect(0x0000ff, p, tilesize);
	  if (e.next != null) {
	    drawLine(0x0000ff, p, e.next.p);
	  }
	  break;
	case PlanAction.JUMP:	// magenta
	  drawRect(0xff00ff, p, tilesize);
	  if (e.mid != null && e.next != null) {
	    drawLine(0xff00ff, p, e.mid);
	    drawLine(0xff00ff, e.mid, e.next.p);
	  }
	  break;
	}
      }
    }
    if (plan.start != null) {
      drawRect(0xffffff, plan.start, tilesize-4);
    }
    drawRect(0x00ff00, plan.goal, tilesize-4);
  }
}

} // package
