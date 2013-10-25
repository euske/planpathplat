package {

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Keyboard;

//  Main 
//
[SWF(width="640", height="480", backgroundColor="#000000", frameRate=24)]
public class Main extends Sprite
{
  private static var _logger:TextField;

  private var _screen:Screen;
  private var _paused:Boolean;
  private var _keydown:int;

  // Main()
  public function Main()
  {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.addEventListener(Event.ACTIVATE, OnActivate);
    stage.addEventListener(Event.DEACTIVATE, OnDeactivate);
    stage.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);

    _logger = new TextField();
    _logger.multiline = true;
    _logger.border = true;
    _logger.width = 400;
    _logger.height = 100;
    _logger.background = true;
    _logger.type = TextFieldType.DYNAMIC;
    //addChild(_logger);

    init();
  }

  // log(x)
  public static function log(... args):void
  {
    var x:String = "";
    for each (var a:Object in args) {
      if (x.length != 0) x += " ";
      x += a;
    }
    _logger.appendText(x+"\n");
    _logger.scrollV = _logger.maxScrollV;
    if (_logger.parent != null) {
      _logger.parent.setChildIndex(_logger, _logger.parent.numChildren-1);
    }
    trace(x);
  }

  // setPauseState(paused)
  private function setPauseState(paused:Boolean):void
  {
    _paused = paused;
  }

  // setScreen(screen)
  private function setScreen(screen:Screen):void
  {
    if (_screen != null) {
      log("close: "+_screen);
      _screen.close();
      _screen.removeEventListener(ScreenEvent.CHANGED, onScreenChanged);
      removeChild(_screen);
    }
    _screen = screen;
    if (_screen != null) {
      log("open: "+_screen);
      _screen.open();
      _screen.addEventListener(ScreenEvent.CHANGED, onScreenChanged);
      addChild(_screen);
    }
  }

  // createScreen(name)
  private function createScreen(name:String):Screen
  {
    switch (name) {
    case GameScreen.NAME:
      return new GameScreen(stage.stageWidth, stage.stageHeight);
    default:
      return null;
    }
  }

  // onScreenChanged(e)
  private function onScreenChanged(e:ScreenEvent):void
  {
    setScreen(createScreen(e.name));
  }

  // OnActivate(e)
  protected function OnActivate(e:Event):void
  {
    setPauseState(false);
  }

  // OnDeactivate(e)
  protected function OnDeactivate(e:Event):void
  {
    setPauseState(true);
  }

  // OnEnterFrame(e)
  protected function OnEnterFrame(e:Event):void
  {
    if (!_paused) {
      if (_screen != null) {
	_screen.update();
      }
    }
  }

  // OnKeyDown(e)
  protected function OnKeyDown(e:KeyboardEvent):void 
  {
    if (_keydown == e.keyCode) return;
    _keydown = e.keyCode;
    switch (e.keyCode) {
    case 80:			// P
      setPauseState(!_paused);
      break;

    case Keyboard.ESCAPE:	// Esc
    case 81:			// Q
      init();
      break;

    default:
      if (_screen != null) {
	_screen.keydown(e.keyCode);
      }
    }
  }

  // OnKeyUp(e)
  protected function OnKeyUp(e:KeyboardEvent):void 
  {
    _keydown = 0;
    if (_screen != null) {
      _screen.keyup(e.keyCode);
    }
  }

  // init()
  protected virtual function init():void
  {
    setScreen(createScreen(GameScreen.NAME));
  }

}

} // package
