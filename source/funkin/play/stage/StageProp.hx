package funkin.play.stage;

import funkin.modding.events.ScriptEvent;
import funkin.graphics.FunkinSprite;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;
import funkin.modding.IScriptedClass.IStateStageProp;

class StageProp extends FunkinSprite implements IStateStageProp
{
  /**
   * An internal name for this prop.
   */
  public var name:String = '';

  public var dynamicZoom:Bool = false;

  public var zoomFactor:Float = 1;

  public function new()
  {
    super();
  }

  /**
   * Called when this prop is added to the stage.
   * @param event
   */
  public function onAdd(event:ScriptEvent):Void {}

  public function onScriptEvent(event:ScriptEvent) {}

  public function onCreate(event:ScriptEvent) {}

  public function onDestroy(event:ScriptEvent) {}

  override function drawComplex(camera:FlxCamera):Void
  {
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    _matrix.translate(-origin.x, -origin.y);
    _matrix.scale(scale.x, scale.y);
    if (bakedRotationAngle <= 0)
    {
      updateTrig();
      if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
    }
    getScreenPosition(_point, camera).subtractPoint(offset);
    _point.add(origin.x, origin.y);
    _matrix.translate(_point.x, _point.y);
    if (isPixelPerfectRender(camera))
    {
      _matrix.tx = Math.round(_matrix.tx / this.scale.x) * this.scale.x;
      _matrix.ty = Math.round(_matrix.ty / this.scale.y) * this.scale.y;
    }
    if (dynamicZoom == true)
    { // this code  was taken and adapted from codename. please support that engine if you see this!
      var zLerp = FlxMath.lerp(1, camera.zoom, zoomFactor) / camera.zoom;
      _matrix.translate(-camera.width / 2, -camera.height / 2);
      _matrix.scale(zLerp, zLerp);
      _matrix.translate(-camera.width / 2, -camera.height / 2);
    }
    camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
  }

  public function onUpdate(event:UpdateScriptEvent) {}
}
