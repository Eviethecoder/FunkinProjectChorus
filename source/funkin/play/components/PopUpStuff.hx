package funkin.play.components;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirection;
import funkin.graphics.FunkinSprite;
import funkin.play.PlayState;
import funkin.util.TimerUtil;
import funkin.util.EaseUtil;
import openfl.utils.Assets;
import funkin.data.hudstyle.HudStyleRegistry;
import funkin.play.hudstyle.HudStyle;

@:nullSafety
class PopUpStuff extends FlxTypedGroup<FunkinSprite>
{
  /**
   * The current note style to use. This determines which graphics to display.
   * For example, Week 6 uses the `pixel` note style, and mods can create their own.
   */
  var hudstyle:HudStyle;

  /**
   * Offsets that are applied to all elements, independent of the note style.
   * Used to allow scripts to reposition the elements.
   */
  public var offsets:Array<Int> = [0, 0];

  override public function new(hudstyle:HudStyle)
  {
    super();

    this.hudstyle = hudstyle;
  }

  public function displayRating(daRating:Null<String>)
  {
    if (daRating == null) daRating = "good";

    var rating:Null<FunkinSprite> = hudstyle.buildJudgementSprite(daRating); // fuckin why do you NULLLL WHYYYYY - past kuru  - its becaus it wasnt reading the json idiot -future kuru
    if (rating == null) return;

    rating.zIndex = 1000;

    rating.x = (FlxG.width * 0.474);
    rating.x -= rating.width / 2;
    rating.y = (FlxG.camera.height * 0.45 - 60);
    rating.y -= rating.height / 2;

    rating.x += offsets[0];
    rating.y += offsets[1];
    var styleOffsets = hudstyle.getJudgementSpriteOffsets(daRating);
    rating.x += styleOffsets[0];
    rating.y += styleOffsets[1];

    rating.acceleration.y = 550;
    rating.velocity.y -= FlxG.random.int(140, 175);
    rating.velocity.x -= FlxG.random.int(0, 10);

    add(rating);

    var fadeEase = hudstyle.isJudgementSpritePixel(daRating) ? EaseUtil.stepped(2) : null;

    FlxTween.tween(rating, {alpha: 0}, 0.2,
      {
        onComplete: function(tween:FlxTween) {
          remove(rating, true);
          rating.destroy();
        },
        startDelay: Conductor.instance.beatLengthMs * 0.001,
        ease: fadeEase
      });
  }

  public function displayCombo(combo:Int = 0):Void
  {
    var seperatedScore:Array<Int> = [];
    var tempCombo:Int = combo;

    while (tempCombo != 0)
    {
      seperatedScore.push(tempCombo % 10);
      tempCombo = Std.int(tempCombo / 10);
    }
    while (seperatedScore.length < 3)
      seperatedScore.push(0);

    // seperatedScore.reverse();

    var daLoop:Int = 1;
    for (digit in seperatedScore)
    {
      var numScore:Null<FunkinSprite> = hudstyle.buildComboNumSprite(digit);
      if (numScore == null) continue;

      numScore.x = (FlxG.width * 0.507) - (36 * daLoop) - 65;
      trace('numScore($daLoop) = ${numScore.x}');
      numScore.y = (FlxG.camera.height * 0.44);

      numScore.x += offsets[0];
      numScore.y += offsets[1];
      var styleOffsets = hudstyle.getComboNumSpriteOffsets(digit);
      numScore.x += styleOffsets[0];
      numScore.y += styleOffsets[1];

      numScore.acceleration.y = FlxG.random.int(250, 300);
      numScore.velocity.y -= FlxG.random.int(130, 150);
      numScore.velocity.x = FlxG.random.float(-5, 5);

      add(numScore);

      var fadeEase = hudstyle.isComboNumSpritePixel(digit) ? EaseUtil.stepped(2) : null;

      FlxTween.tween(numScore, {alpha: 0}, 0.2,
        {
          onComplete: function(tween:FlxTween) {
            remove(numScore, true);
            numScore.destroy();
          },
          startDelay: Conductor.instance.beatLengthMs * 0.002,
          ease: fadeEase
        });

      daLoop++;
    }
  }
}
