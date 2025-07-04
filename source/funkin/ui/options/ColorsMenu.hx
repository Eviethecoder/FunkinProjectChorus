package funkin.ui.options;

import funkin.data.notestyle.NoteStyleRegistry;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.ui.options.OptionsState.Page;
import funkin.play.notes.NoteSprite;

class ColorsMenu extends Page
{
  var curSelected:Int = 0;
  var selectedcolornumber:Int = 0;

  var grpNotes:FlxTypedGroup<NoteSprite>;

  var leftnotecoloroffsets:Array<Float> = [1, 0.5, 0.1];
  var downnotecoloroffsets:Array<Float> = [0, 0, 0];
  var upnotecoloroffsets:Array<Float> = [0, 0, 0];
  var rightnotecoloroffsets:Array<Float> = [0, 0, 0];

  public function new()
  {
    super();

    grpNotes = new FlxTypedGroup<NoteSprite>();
    add(grpNotes);

    for (i in 0...4)
    {
      var note:NoteSprite = new NoteSprite(NoteStyleRegistry.instance.fetchDefault(), i);

      note.x = (100 * i) + i;
      note.screenCenter(Y);

      switch (i)
      {
        case(0):
          note.setColorTransform(leftnotecoloroffsets[0], leftnotecoloroffsets[1], leftnotecoloroffsets[2]);
        case(1):
          note.setColorTransform(downnotecoloroffsets[0], downnotecoloroffsets[1], downnotecoloroffsets[2]);
        case(2):
          note.setColorTransform(upnotecoloroffsets[0], upnotecoloroffsets[1], upnotecoloroffsets[2]);
        case(3):
          note.setColorTransform(rightnotecoloroffsets[0], rightnotecoloroffsets[1], rightnotecoloroffsets[2]);
      }

      var _effectSpr:FlxEffectSprite = new FlxEffectSprite(note, [new FlxOutlineEffect(FlxOutlineMode.FAST, FlxColor.WHITE, 4, 1)]);
      add(_effectSpr);
      _effectSpr.y = 0;
      _effectSpr.x = i * 130;
      _effectSpr.scale.x = _effectSpr.scale.y = 0.7;
      // _effectSpr.setGraphicSize();
      _effectSpr.height = note.height;
      _effectSpr.width = note.width;

      // _effectSpr.updateHitbox();

      grpNotes.add(note);
    }
  }

  override function update(elapsed:Float)
  {
    if (controls.UI_RIGHT_P) curSelected += 1;
    if (FlxG.keys.justPressed.SHIFT && controls.UI_RIGHT_P)
    {
      if (selectedcolornumber == 2)
      {
        selectedcolornumber = 0;
      }
      else
        selectedcolornumber += 1;
    }
    if (controls.UI_LEFT_P) curSelected -= 1;

    if (curSelected < 0) curSelected = grpNotes.members.length - 1;
    if (curSelected >= grpNotes.members.length) curSelected = 0;

    if (controls.UI_UP)
    {
      switch (curSelected)
      {
        case(0):
          leftnotecoloroffsets[selectedcolornumber] += 1;
        case(1):
          leftnotecoloroffsets[selectedcolornumber]++;
        case(2):
          downnotecoloroffsets[selectedcolornumber]++;
        case(3):
          upnotecoloroffsets[selectedcolornumber]++;
        case(4):
          rightnotecoloroffsets[selectedcolornumber]++;
      }
    }

    if (controls.UI_DOWN)
    {
      // grpNotes.members[curSelected].colorSwap.update(-elapsed * 0.3);
      // Note.arrowColors[curSelected] += -elapsed * 0.3;
    }

    super.update(elapsed);
  }
}
