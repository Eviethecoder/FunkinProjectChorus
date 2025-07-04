package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.options.OptionsState.Page;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.audio.FunkinSound;
import funkin.ui.options.MenuItemEnums;
import flixel.math.FlxMath;
import funkin.ui.options.items.CheckboxPreferenceItem;
import funkin.ui.options.items.NumberPreferenceItem;
import funkin.ui.options.items.EnumPreferenceItem;

class PreferencesMenu extends Page
{
  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;

  var menuCamera:FlxCamera;
  var camFollow:FlxObject;

  public static var curSelected:Int = 0;

  private var descBox:FlxSprite;
  private var descText:FlxText;

  public var optionsArray:Array<String>;

  public function new()
  {
    super();

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;
    optionsArray = [];

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    createPrefItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.06);
    var margin = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
    menuCamera.minScrollY = 0;

    descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    descBox.alpha = 0.6;
    descBox.scrollFactor.set();
    add(descBox);

    descText = new FlxText(50, 600, 1180, "", 32);
    descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    descText.scrollFactor.set();
    descText.borderSize = 2.4;
    add(descText);

    items.onChange.add(function(selected) {
      camFollow.y = selected.y;
    });
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefItemCheckbox('Naughtyness', 'Toggle displaying raunchy content', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);

    // Creates a new NumberPreferenceItem set up to handle percentages
    createPrefItemPercentage('Note hit sound volume', 'Enable to play a sound when hitting notes', function(value:Int):Void {
      Preferences.noteHitSoundVolume = value;
      trace(Preferences.noteHitSoundVolume);
      var hitSound:String = Preferences.noteHitSound;
      FunkinSound.playOnce(Paths.sound('noteHitSounds/${hitSound}') ?? Paths.sound('noteHitSounds/Psych'), Preferences.noteHitSoundVolume / 100);
    }, Preferences.noteHitSoundVolume);
    // NoteHitSoundType would be a string enum defined in MenuItemEnums.hx
    createPrefItemEnum('Timebar Type', 'changes the Timebar style/disables it', [
      TimebarType.None => "None",
      TimebarType.Classic => "Classic",
      TimebarType.Gradient => "Gradient",
    ], function(value:String):Void {
      Preferences.timebar = value;
    }, Preferences.timebar);

    createPrefItemEnum('HudStyle Overide', 'overides any use of the funkin style with this one. in beta', [
      Hudstyle.Funkin => "Funkin",
      Hudstyle.Test1 => "test1",
      Hudstyle.Test2 => "test2",
      Hudstyle.Test3 => "Gtest3",
    ], function(value:String):Void {
      Preferences.timebar = value;
    }, Preferences.timebar);

    createPrefItemEnum('Ranking Dificulty',
      'The Ranking Dificulty. Nightmare only counts Killers. Intended is Killers AND Sick. And pussy is Killer,Sick, And Good', [
        Rankingtype.Hard => "Nightmare",
        Rankingtype.Intended => "Intended",
        Rankingtype.Pussy => "Pussy",

      ], function(value:String):Void {
        Preferences.rankingtype = value;
      }, Preferences.rankingtype);

    // NoteHitSoundType would be a string enum defined in MenuItemEnums.hx
    createPrefItemEnum('Note hit sound-opponent', 'changes the opponents hit sounds in charter (will be moved to charter later)', [
      NoteHitSoundType.None => "None",
      NoteHitSoundType.Psych => "Psych",
      NoteHitSoundType.Beep1 => "Beep1",
      NoteHitSoundType.Beep2 => "Beep2",
    ], function(value:String):Void {
      Preferences.noteHitSoundopp = value;
      var hitSound:String = value + "Hit";
      trace(Preferences.noteHitSoundopp);
      FunkinSound.playOnce(Paths.sound('noteHitSounds/${hitSound}') ?? Paths.sound('noteHitSounds/Psych'),);
    }, Preferences.noteHitSoundopp);
    // NoteHitSoundType would be a string enum defined in MenuItemEnums.hx
    createPrefItemEnum('Note hit sound', 'Enable to play a sound when hitting notes', [
      NoteHitSoundType.None => "None",
      NoteHitSoundType.Psych => "Psych",
      NoteHitSoundType.Beep1 => "Beep1",
      NoteHitSoundType.Beep2 => "Beep2",
    ], function(value:String):Void {
      Preferences.noteHitSound = value;
      var hitSound:String = value + "Hit";
      trace(Preferences.noteHitSound);
      FunkinSound.playOnce(Paths.sound('noteHitSounds/${hitSound}') ?? Paths.sound('noteHitSounds/Psych'),);
    }, Preferences.noteHitSound);
    createPrefItemCheckbox('Middlescroll', 'Enable to make notes centered', function(value:Bool):Void {
      Preferences.middlescroll = value;
    }, Preferences.middlescroll);
    createPrefItemCheckbox('Ghosttapping', 'Enable to make hitting a note when none is prefsent do nothing', function(value:Bool):Void {
      Preferences.ghostapping = value;
    }, Preferences.ghostapping);
    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
    }, Preferences.flashingLights);
    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);
    createPrefItemCheckbox('Debug Display', 'Enable to show FPS and other debug stats', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Auto Pause', 'Automatically pause the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
    #if web
    createPrefItemCheckbox('Unlocked Framerate', 'Enable to unlock the framerate', function(value:Bool):Void {
      Preferences.unlockedFramerate = value;
    }, Preferences.unlockedFramerate);
    #else
    createPrefItemNumber('FPS', 'The maximum framerate that the game targets', function(value:Float) {
      Preferences.framerate = Std.int(value);
    }, null, Preferences.framerate, 30, 300, 5, 0);
    #end
  }

  function changeItem(change:Int = 0)
  {
    curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);
    descText.text = optionsArray[curSelected];
    trace(descText.text);
    trace(curSelected);
    descText.screenCenter(Y);
    descText.y += 270;
    descBox.setPosition(descText.x - 10, descText.y - 10);
    descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
    descBox.updateHitbox();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (controls.UI_UP_P)
    {
      changeItem(-1);
    }

    if (controls.UI_DOWN_P)
    {
      changeItem(1);
    }

    // Indent the selected item.
    items.forEach(function(daItem:TextMenuItem) {
      var thyOffset:Int = 0;

      // Initializing thy text width (if thou text present)
      var thyTextWidth:Int = 0;
      if (Std.isOfType(daItem, EnumPreferenceItem)) thyTextWidth = cast(daItem, EnumPreferenceItem).lefthandText.getWidth();
      else if (Std.isOfType(daItem, NumberPreferenceItem)) thyTextWidth = cast(daItem, NumberPreferenceItem).lefthandText.getWidth();

      if (thyTextWidth != 0)
      {
        // Magic number because of the weird offset thats being added by default
        thyOffset += thyTextWidth - 75;
      }

      if (items.selectedItem == daItem)
      {
        thyOffset += 150;
      }
      else
      {
        thyOffset += 120;
      }

      daItem.x = thyOffset;
    });
  }

  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (items.length - 1 + 1), defaultValue, prefDesc);

    items.createItem(0, (120 * items.length) + 30, prefName, AtlasFont.BOLD, function() {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
    }, prefDesc);
    optionsArray.push(prefDesc);

    preferenceItems.add(checkbox);
  }

  /**
   * Creates a pref item that works with general numbers
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param valueFormatter Will get called every time the game needs to display the float value; use this to change how the displayed value looks
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   * @param min Minimum value (example: 0)
   * @param max Maximum value (example: 10)
   * @param step The value to increment/decrement by (default = 0.1)
   * @param precision Rounds decimals up to a `precision` amount of digits (ex: 4 -> 0.1234, 2 -> 0.12)
   */
  function createPrefItemNumber(prefName:String, prefDesc:String, onChange:Float->Void, ?valueFormatter:Float->String, defaultValue:Int, min:Int, max:Int,
      step:Float = 0.1, precision:Int):Void
  {
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, step, precision, prefDesc, onChange, valueFormatter);
    items.addItem(prefName, item, prefDesc);
    optionsArray.push(prefDesc);
    preferenceItems.add(item.lefthandText);
  }

  /**
   * Creates a pref item that works with number percentages
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   * @param min Minimum value (default = 0)
   * @param max Maximum value (default = 100)
   */
  function createPrefItemPercentage(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, min:Int = 0, max:Int = 100):Void
  {
    var newCallback = function(value:Float) {
      onChange(Std.int(value));
    };
    var formatter = function(value:Float) {
      return '${value}%';
    };
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, 10, 0, prefDesc, newCallback, formatter);
    items.addItem(prefName, item, prefDesc);
    optionsArray.push(prefDesc);
    preferenceItems.add(item.lefthandText);
  }

  /**
   * Creates a pref item that works with enums
   * @param values Maps enum values to display strings _(ex: `NoteHitSoundType.PingPong => "Ping pong"`)_
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   */
  function createPrefItemEnum(prefName:String, prefDesc:String, values:Map<String, String>, onChange:String->Void, defaultValue:String):Void
  {
    var item = new EnumPreferenceItem(0, (120 * items.length) + 30, prefName, values, defaultValue, onChange);
    items.addItem(prefName, item, prefDesc);
    optionsArray.push(prefDesc);
    preferenceItems.add(item.lefthandText);
  }
}
