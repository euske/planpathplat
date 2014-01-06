package {

import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public var scene:Scene;

  public function PlanVisualizer(scene:Scene)
  {
    super();
    this.scene = scene;
  }

  // update()
  public function update(plan:PlanMap, start:Point=null):void
  {
    graphics.clear();
    if (plan == null) return;

    var y0:int = Math.floor(window.top/tilesize);
    var y1:int = Math.ceil(window.bottom/tilesize);
    var x0:int = Math.floor(window.left/tilesize); 
    var x1:int = Math.ceil(window.right/tilesize);
    
    for each (var a:PlanAction in plan.getAllActions()) {
      if (a.context != null) continue;
      var p:Point = a.p;
      if (p.x < x0 || x1 <= p.x || p.y < y0 || y1 <= p.y) continue;
      var c:int = 0x0000ff;
      switch (a.type) {
      case PlanAction.WALK:	// white
	drawRect(0xffffff, p, tilesize);
	break;
	case PlanAction.CLIMB:	// green
	  drawRect(0x00ff00, p, tilesize);
	  break;
	case PlanAction.FALL:	// blue
	  drawRect(0x0000ff, p, tilesize);
	  if (a.next != null) {
	    drawLine(0x0000ff, p, a.next.p);
	  }
	  break;
	case PlanAction.JUMP:	// magenta
	  drawRect(0xff00ff, p, tilesize);
	  if (a.next != null && a.next.next != null) {
	    drawLine(0xff00ff, p, a.next.p);
	    drawLine(0xff00ff, a.next.p, a.next.next.p);
	  }
	  break;
      }
    }
    if (start != null) {
      drawRect(0xffffff, start, tilesize-4);
    }
    drawRect(0x00ff00, plan.goal, tilesize-4);
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

}

} // package
