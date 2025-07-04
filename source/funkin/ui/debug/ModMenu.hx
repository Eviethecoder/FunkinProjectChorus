package funkin.ui.debug;

import funkin.modding.PolymodHandler;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.save.Save;
import polymod.Polymod;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flash.display.BitmapData;
import funkin.ui.options.OptionsState.Page;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import funkin.graphics.shaders.HSVShader;
import funkin.input.Cursor;
import flixel.addons.effects.chainable.FlxEffectSprite;

class ModMenu extends MusicBeatState
{
  var grpMods:FlxTypedSpriteGroup<ModMenuSprite>;
  var enabledMods:Array<ModMetadata> = [];
  var enabledModsids:Array<String> = [];
  var detectedMods:Array<ModMetadata> = [];

  public var description:FlxText;
  public var modName:FlxText;

  var curSelected:Int = 0;

  public function new():Void
  {
    super();
  }

  override function create():Void
  {
    // Updating Discord Rich Presence
    funkin.api.discord.DiscordClient.instance.setPresence({state: 'Choosing Mods', details: null});
    // Create the green background.
    bgColor = 0x00000000;
    var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    menuBG.color = 0xFF4CAF50;
    menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
    menuBG.updateHitbox();
    menuBG.screenCenter();
    menuBG.scrollFactor.set(0, 0);
    add(menuBG);
    // Show the mouse cursor.
    Cursor.show();

    grpMods = new FlxTypedSpriteGroup<ModMenuSprite>();
    add(grpMods);

    description = new FlxText(50, 600, 1180, "", 32);
    description.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    description.scrollFactor.set();
    description.borderSize = 2.4;
    add(description);
    modName = new FlxText(50, 0, 1180, "", 32);
    modName.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    modName.scrollFactor.set();
    modName.borderSize = 2.4;
    add(modName);

    refreshModList();
  }

  override function update(elapsed:Float)
  {
    if (FlxG.keys.justPressed.R) refreshModList();

    if (controls.UI_UP_P) selections(-1);
    if (controls.UI_DOWN_P) selections(1);
    if (FlxG.keys.justPressed.SPACE)
    {
      switch (grpMods.members[curSelected].modEnabled)
      {
        case true:
          grpMods.members[curSelected].disableIcon(false);

        case false:
          grpMods.members[curSelected].disableIcon(true);
      }
    }

    if (FlxG.keys.justPressed.I && curSelected != 0)
    {
      var oldOne = grpMods.members[curSelected - 1];
      grpMods.members[curSelected - 1] = grpMods.members[curSelected];
      grpMods.members[curSelected] = oldOne;
      selections(-1);
    }

    if (FlxG.keys.justPressed.P)
    {
      savemodpreff();
    }

    if (FlxG.keys.justPressed.K && curSelected < grpMods.members.length - 1)
    {
      var oldOne = grpMods.members[curSelected + 1];
      grpMods.members[curSelected + 1] = grpMods.members[curSelected];
      grpMods.members[curSelected] = oldOne;
      selections(1);
    }

    super.update(elapsed);
  }

  function savemodpreff():Void
  {
    if (enabledMods != [])
    {
      enabledMods = [];
    }
    if (enabledModsids != [])
    {
      enabledModsids = [];
    }
    for (index in 0...detectedMods.length)
    {
      if (grpMods.members[index].modEnabled == true)
      {
        trace('mod should be enabled');
        enabledMods.push(detectedMods[index]);
      }
      else
      {
        trace('mod is disabled');
      }
    }
    trace(enabledMods);

    for (i in enabledMods)
    {
      enabledModsids.push(i.id);
    }

    trace(enabledModsids);
    Save.instance.enabledModIds = enabledModsids;
    trace('reloading assets');

    PolymodHandler.forceReloadAssetsmodmenureset();
  }

  function selections(change:Int = 0):Void
  {
    trace(curSelected);
    if (change == -1 && curSelected != 0)
    {
      trace('change = -1');
      FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
      FlxTween.tween(grpMods, {x: grpMods.x + 520}, 0.2,
        {
          ease: FlxEase.expoOut
        });
    }

    if (change == 1 && curSelected != detectedMods.length - 1)
    {
      trace('change = 1');
      FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
      FlxTween.tween(grpMods, {x: grpMods.x - 520}, 0.2,
        {
          ease: FlxEase.expoOut,
          onComplete: function(tween:FlxTween) {
          }
        });
    }

    curSelected += change;
    if (curSelected <= 0) curSelected = 0;
    else if (curSelected >= detectedMods.length) curSelected = detectedMods.length - 1;
    for (icon in 0...grpMods.length)
    {
      var i:Int = icon;
      if (change == 0) {}

      if (icon == curSelected)
      {
        description.text = grpMods.members[icon].metaData.description;
        modName.text = grpMods.members[icon].metaData.title;
        FlxTween.tween(grpMods.members[icon], {alpha: 1}, 0.2);
      }
      else
        FlxTween.tween(grpMods.members[icon], {alpha: 0.5}, 0.2);
    }
  }

  function refreshModList():Void
  {
    while (grpMods.members.length > 0)
    {
      grpMods.remove(grpMods.members[0], true);
    }

    #if desktop
    detectedMods = PolymodHandler.getAllMods();

    trace('ModMenu: Detected ${detectedMods.length} mods');

    for (index in 0...detectedMods.length)
    {
      var modMetadata:ModMetadata = detectedMods[index];

      var modName:String = modMetadata.title;
      var icon:ModMenuSprite = new ModMenuSprite(450 + (520 * index), 0, modMetadata);
      // icon.text = modName;
      icon.initicon();
      icon.ID = index;
      icon.screenCenter(Y);

      grpMods.add(icon);
    }

    for (icon in 0...grpMods.length)
    {
      var icon:ModMenuSprite = grpMods.members[icon];
      for (i in 0...Save.instance.enabledModIds.length)
        if (icon.metaData.id != Save.instance.enabledModIds[i] && icon.modEnabled == true)
        {
          trace('mod Disabled.');
          {
            icon.modEnabled = false;
            icon.disableIcon(true);
          }
          if (icon.metaData.id == Save.instance.enabledModIds[i] && icon.modEnabled == false)
          {
            trace('mod enabled.');
            {
              icon.modEnabled = true;
              icon.disableIcon(false);
              break;
            }
          }
        }
    #end
      selections();
    }
  }

  /*
    *this will handel all the info from the metadata. includding the name and description
   */
  override function destroy():Void
  {
    super.destroy();

    // Hide the mouse cursor on other states.
    Cursor.hide();
  }
} class ModMenuSprite extends FlxSprite
{
  public var modEnabled:Bool = true;
  public var metaData:ModMetadata;
  public var hsvShader:HSVShader;

  public function new(x:Float, y:Float, metadata:ModMetadata, ?SimpleGraphic:FlxGraphicAsset)
  {
    super(x, y);

    this.metaData = metadata;
    this.hsvShader = new HSVShader();
  }

  public function initicon()
  {
    this.loadGraphic(BitmapData.fromBytes(metaData.icon));
    this.shader = hsvShader;
  }

  public function disableIcon(state:Bool)
  {
    switch (state)
    {
      case false:
        desaturate(0.2);
        this.modEnabled = false;

      case true:
        desaturate(1);
        this.modEnabled = true;
    }
    trace(modEnabled);
  }

  // shader code from note class.
  public function desaturate(value:Float):Void
  {
    this.hsvShader.saturation = value;
  }

  public function setHue(hue:Float):Void
  {
    this.hsvShader.hue = hue;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
  }
}
