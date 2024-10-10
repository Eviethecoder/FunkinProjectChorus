package funkin.data.hudstyle;

import haxe.DynamicAccess;
import funkin.data.animation.AnimationData;

/**
 * A type definition for the data in a hud style JSON file.
 * @see https://lib.haxe.org/p/json2object/
 */
typedef HudStyleData =
{
  /**
   * The version number of the hud style data schema.
   * When making changes to the hud style data format, this should be incremented,
   * and a migration function should be added to HudStyleDataParser to handle old versions.
   */
  @:default(funkin.data.hudstyle.HudStyleRegistry.HUD_STYLE_DATA_VERSION)
  var version:String;

  /**
   * The readable title of the hud style.
   */
  var name:String;

  /**
   * The author of the hud style.
   */
  var author:String;

  /**
   * The hud style to use as a fallback/parent.
   * @default null
   */
  @:optional
  var fallback:Null<String>;

  /**
   * Data for each of the assets in the hud style.
   */
  var assets:HudStyleAssetsData;
}

typedef HudStyleAssetsData =
{
  /**
   * The sprites for the huds.
   * @default The basegame Healthbar
   */
  var healthbar:HudStyleAssetData<HudStyleData_Healthbar>;

  /**
   * The sprites for the timebar.
   * @default The basegame Timebar
   */
  var timebar:HudStyleAssetData<HudStyleData_Timebar>;

  /**
   * The THREE sound (and an optional pre-READY graphic).
   */
  @:optional
  var countdownThree:HudStyleAssetData<HudStyleData_Countdown>;

  /**
   * The TWO sound and READY graphic.
   */
  @:optional
  var countdownTwo:HudStyleAssetData<HudStyleData_Countdown>;

  /**
   * The ONE sound and SET graphic.
   */
  @:optional
  var countdownOne:HudStyleAssetData<HudStyleData_Countdown>;

  /**
   * The GO sound and GO! graphic.
   */
  @:optional
  var countdownGo:HudStyleAssetData<HudStyleData_Countdown>;

  /**
   * The SICK! judgement.
   */
  @:optional
  var judgementKiller:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The SICK! judgement.
   */
  @:optional
  var judgementSick:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The GOOD! judgement.
   */
  @:optional
  var judgementGood:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The BAD! judgement.
   */
  @:optional
  var judgementBad:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The SHIT! judgement.
   */
  @:optional
  var judgementShit:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The early timing.
   */
  @:optional
  var earlyshit:HudStyleAssetData<HudStyleData_Judgement>;

  /**
   * The late timing
   */
  @:optional
  var lateshit:HudStyleAssetData<HudStyleData_Judgement>;

  @:optional
  var comboNumber0:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber1:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber2:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber3:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber4:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber5:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber6:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber7:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber8:HudStyleAssetData<HudStyleData_ComboNum>;

  @:optional
  var comboNumber9:HudStyleAssetData<HudStyleData_ComboNum>;
}

/**
 * Data shared by all Hud style assets.
 */
typedef HudStyleAssetData<T> =
{
  /**
   * The image to use for the asset. May be a Sparrow sprite sheet.
   */
  var assetPath:String;

  /**
   * The scale to render the prop at.
   * @default 1.0
   */
  @:default(1.0)
  @:optional
  var scale:Float;

  /**
   * Offset the sprite's position by this amount.
   * @default [0, 0]
   */
  @:default([0, 0])
  @:optional
  var offsets:Null<Array<Float>>;

  /**
   * If true, the prop is a pixel sprite, and will be rendered without anti-aliasing.
   */
  @:default(false)
  @:optional
  var isPixel:Bool;

  /**
   * If true, animations will be played on the graphic.
   * @default `false` to save performance.
   */
  @:default(false)
  @:optional
  var animated:Bool;

  /**
   * The structure of this data depends on the asset.
   */
  var data:T;
}

typedef HudStyleData_Timebar =
{
  /**
   * Offset the sprite's Barsize by this amount.
   * @default [0, 0]
   */
  @:default([0, 0])
  @:optional
  var baroffsets:Array<Float>;

  /**
   * the style of bar. clasic is basic flxbar while psych is psych engines healthbar class.
   * @default clasic
   */
  var Timebarstyle:String;
}

typedef HudStyleData_Healthbar =
{
  /**
   * Offset the sprite's Barsize by this amount.
   * @default [0, 0]
   */
  @:default([0, 0])
  var baroffsets:Array<Float>;

  /**
   * the style of bar. clasic is basic flxbar while psych is psych engines healthbar class.
   * @default clasic
   */
  @:optional
  var Healthbarstyle:String;
}

typedef HudStyleData_Countdown =
{
  var audioPath:String;
}

typedef HudStyleData_Judgement = {}
typedef HudStyleData_ComboNum = {}
