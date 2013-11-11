package {

import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public var plan:PlanMap;
  public var scene:Scene;

  public function PlanVisualizer(scene:Scene)
  {
    super();
    this.scene = scene;
  }

  private function get window():Rectangle
  {
    return scene.window;
  }
  private function get tilesize():int
  {
    return scene.tilemap.tilesize;
  }

  private function drawRect(color:uint, p:Point, size:int):void
  {
    graphics.lineStyle(0, color);
    graphics.drawRect((p.x+0.5)*tilesize-size/2-window.left, 
		      (p.y+0.5)*tilesize-size/2-window.top, 
		      size, size);
  }

  private function drawLine(color:uint, src:Point, dst:Point):void
  {
    graphics.lineStyle(0, color);
    graphics.moveTo((src.x+0.5)*tilesize-window.left,
		    (src.y+0.5)*tilesize-window.top);
    graphics.lineTo((dst.x+0.5)*tilesize-window.left,
		    (dst.y+0.5)*tilesize-window.top);
  }

  public function repaint():void
  {
    graphics.clear();
    if (plan == null) return;

    for (var y:int = Math.floor(window.left/tilesize); 
	 y < Math.ceil(window.bottom/tilesize); y++) {
      for (var x:int = Math.floor(window.left/tilesize); 
	   x < Math.ceil(window.right/tilesize); x++) {
	var e:PlanAction = plan.getAction(x, y);
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
