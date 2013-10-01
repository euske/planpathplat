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

  private var _state:GameState;
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

  // setGameState(state)
  private function setGameState(state:GameState):void
  {
    if (_state != null) {
      log("close: "+_state);
      _state.close();
      _state.removeEventListener(GameStateEvent.CHANGED, onStateChanged);
      removeChild(_state);
    }
    _state = state;
    if (_state != null) {
      log("open: "+_state);
      _state.open();
      _state.addEventListener(GameStateEvent.CHANGED, onStateChanged);
      addChild(_state);
    }
  }

  // createGameState(name)
  private function createGameState(name:String):GameState
  {
    switch (name) {
    case MainState.NAME:
      return new MainState(stage.stageWidth, stage.stageHeight);
    default:
      return null;
    }
  }

  // onStateChanged(e)
  private function onStateChanged(e:GameStateEvent):void
  {
    setGameState(createGameState(e.name));
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
      if (_state != null) {
	_state.update();
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
      if (_state != null) {
	_state.keydown(e.keyCode);
      }
    }
  }

  // OnKeyUp(e)
  protected function OnKeyUp(e:KeyboardEvent):void 
  {
    _keydown = 0;
    if (_state != null) {
      _state.keyup(e.keyCode);
    }
  }

  // init()
  protected virtual function init():void
  {
    setGameState(createGameState(MainState.NAME));
  }

}

} // package
