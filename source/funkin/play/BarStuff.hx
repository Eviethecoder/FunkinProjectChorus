package funkin.play;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirection;
import funkin.graphics.FunkinSprite;
import funkin.play.PlayState;
import funkin.util.TimerUtil;
import funkin.util.EaseUtil;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import openfl.utils.Assets;
import funkin.Preferences;
import funkin.data.hudstyle.HudStyleRegistry;
import funkin.play.hudstyle.HudStyle;

/**
 *  this class handeles the new hudstyle system for hp and time bar. allowing for easy hud swaps
 */
class BarStuff extends FlxTypedGroup<FlxBasic>
{
  /**
   * The current note style to use. This determines which graphics to display.
   * For example, Week 6 uses the `pixel` note style, and mods can create their own.
   */
  var hudstyle:HudStyle;

  // the call for the bars to update
  public var shouldupdate:Bool = true;

  /**
   * Offsets that are applied to all elements, independent of the note style.
   * Used to allow scripts to reposition the elements.
   */
  public var offsets:Array<Int> = [0, 0];

  /**
   * The bar which displays the player's health.
   * Dynamically updated based on the value of `healthLerp` (which is based on `health`).
   */
  public var healthBar:FlxBar;

  /**
   * The FlxText which displays the current time.
   */
  public var timeTxt:FlxText;

  /**


    /**
    * The bar which displays the time.
   */
  public var timeBar:FlxBar;

  /**
   * The background image used for the time bar.
   * Emma says the image is slightly skewed so I'm leaving it as an image instead of a `createGraphic`.
   */
  public var timeBarBG:FunkinSprite;

  /**
   * The background image used for the health bar.
   * Emma says the image is slightly skewed so I'm leaving it as an image instead of a `createGraphic`.
   */
  public var healthBarBG:FunkinSprite;

  override public function new(hudstyle:HudStyle)
  {
    super();

    this.hudstyle = hudstyle;
  }

  public function barcreation(dad:Array<Int>, boyfriend:Array<Int>)
  {
    var emptyarray:Array<FlxColor> = [FlxColor.BLACK, FlxColor.BLACK];
    var fullyarray:Array<FlxColor> = [
      FlxColor.fromRGB(dad[0], dad[1], dad[2]),
      FlxColor.fromRGB(boyfriend[0], boyfriend[1], boyfriend[2])
    ];

    var healthBarYPos:Float = Preferences.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;
    healthBarBG = FunkinSprite.create(0, healthBarYPos, hudstyle.getHealthbarAssetPath());
    healthBarBG.screenCenter(X);
    healthBarBG.scrollFactor.set(0, 0);
    healthBarBG.zIndex = 801;

    var healthoffsets = hudstyle.getHealthbarbarOffsets();
    var healthspriteoffsets = hudstyle.getHealthbarspriteOffsets();

    healthBar = new FlxBar(healthBarBG.x + healthspriteoffsets[0], healthBarBG.y + healthspriteoffsets[1], RIGHT_TO_LEFT,
      Std.int(healthBarBG.width + healthoffsets[0]), Std.int(healthBarBG.height + healthoffsets[1]), this, null, 0, 2);
    healthBar.value = PlayState.instance.healthLerp;
    healthBar.scrollFactor.set();
    healthBar.createFilledBar(FlxColor.fromRGB(dad[0], dad[1], dad[2]), FlxColor.fromRGB(boyfriend[0], boyfriend[1], boyfriend[2]));
    healthBar.zIndex = 800;
    add(healthBar);
    add(healthBarBG);

    if (Preferences.timebar != 'None')
    {
      var timeBarYPos:Float = Preferences.downscroll ? FlxG.height * 0.97 : FlxG.height;
      timeBarBG = FunkinSprite.create(0, timeBarYPos, hudstyle.getTimebarAssetPath());
      timeBarBG.screenCenter(X);
      timeBarBG.scrollFactor.set(0, 0);
      timeBarBG.zIndex = 800;
      add(timeBarBG);

      var timeoffsets = hudstyle.getTimebarspriteOffsets();
      var timespriteoffsets = hudstyle.getTimebarbarOffsets();

      timeBar = new FlxBar(timeBarBG.x + timeoffsets[0], timeBarBG.y + timeoffsets[1], LEFT_TO_RIGHT, Std.int(timeBarBG.width + timespriteoffsets[0]),
        Std.int(timeBarBG.height + timespriteoffsets[1]), this, null, 0, 1);
      timeBar.scrollFactor.set();

      switch (Preferences.timebar)
      {
        case 'Classic':
          timeBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
        case "Gradient":
          timeBar.createGradientBar(emptyarray, fullyarray);
      }
      timeBar.zIndex = 802;
      add(timeBar);

      // The time text.
      timeTxt = new FlxText(timeBar.x + (FlxG.width / 2) - 248, 19, 400, "", 32);
      timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      timeTxt.scrollFactor.set();
      timeTxt.alpha = 1;
      timeTxt.y = timeBar.y - 10.30;
      timeTxt.screenCenter(X);
      timeTxt.borderSize = 2;
      timeTxt.text = 'unset';
      timeTxt.zIndex = 810;
      add(timeTxt);
    }
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    if (shouldupdate)
    {
      healthBar.value = PlayState.instance.healthLerp;
      timeBar.value = PlayState.instance.songPercent;
    }
  }
}
