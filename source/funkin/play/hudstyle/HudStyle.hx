package funkin.play.hudstyle;

import funkin.play.Countdown;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.data.animation.AnimationData;
import funkin.data.IRegistryEntry;
import funkin.graphics.FunkinSprite;
import funkin.data.hudstyle.HudStyleData;
import funkin.data.hudstyle.HudStyleRegistry;
import funkin.util.assets.FlxAnimationUtil;

using funkin.data.animation.AnimationData.AnimationDataUtil;

/**
 * Holds the data for what assets to use for a note style,
 * and provides convenience methods for building sprites based on them.
 */
@:nullSafety
class HudStyle implements IRegistryEntry<HudStyleData>
{
  /**
   * The ID of the note style.
   */
  public final id:Null<String>;

  /**
   * Note style data as parsed from the JSON file.
   */
  public final _data:HudStyleData;

  /**
   * The note style to use if this one doesn't have a certain asset.
   * This can be recursive, ehe.
   */
  final fallback:Null<HudStyle>;

  /**
   * @param id The ID of the JSON file to parse.
   */
  public function new(id2:String)
  {
    this.id = id2;
    _data = _fetchData(id2);
    var fallbackID = _data.fallback;

    if (fallbackID != null) this.fallback = HudStyleRegistry.instance.fetchEntry(fallbackID);
  }

  /**
   * Get the readable name of the note style.
   * @return String
   */
  public function getName():String
  {
    return _data.name;
  }

  /**
   * Get the author of the note style.
   * @return String
   */
  public function getAuthor():String
  {
    return _data.author;
  }

  /**
   * Get the note style ID of the parent note style.
   * @return The string ID, or `null` if there is no parent.
   */
  public function getFallbackID():Null<String>
  {
    return _data.fallback;
  }

  public function buildHealthbar():Void {}

  var noteFrames:Null<FlxAtlasFrames> = null;

  // todo: healthbar anim frame shit
  // function buildHealthbarFrames(force:Bool = false):Null<FlxAtlasFrames>
  // {
  //   var healthbarAssetPath = getHealthbarAssetPath();
  //   if (healthbarAssetPath == null) return null;
  //   if (!FunkinSprite.isTextureCached(Paths.image(healthbarAssetPath)))
  //   {
  //     FlxG.log.warn('Note texture is not cached: ${healthbarAssetPath}');
  //   }
  //   // Purge the note frames if the cached atlas is invalid. todo: add healthbarframe support
  //   @:nullSafety(Off)
  //   {
  //    // if (healthbarFrames?.parent?.isDestroyed ?? false) healthbarFrames = null;
  //   }
  //   if (noteFrames != null && !force) return noteFrames;
  //   var healthbarAssetPath = getHealthbarAssetPath();
  //   if (healthbarAssetPath == null) return null;
  //   healthbarFrames = Paths.getSparrowAtlas(healthbarAssetPath, getHealthbarAssetLibrary());
  //   if (healthbarFrames == null)
  //   {
  //     throw 'Could not load note frames for note style: $id';
  //   }
  //   return healthbarFrames;
  // }
  public function getTimebarAssetPath(raw:Bool = false):Null<String>
  {
    if (raw)
    {
      var rawPath:Null<String> = _data?.assets?.timebar?.assetPath;
      if (rawPath == null && fallback != null) return fallback.getTimebarAssetPath(true);
      return rawPath;
    }

    // library:path
    var parts = getTimebarAssetPath(true)?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length == 0) return null;
    if (parts.length == 1) return getTimebarAssetPath(true);
    return parts[1];
  }

  function getTimebarAssetLibrary():Null<String>
  {
    // library:path
    var parts = getTimebarAssetLibrary()?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length == 0) return null;
    if (parts.length == 1) return null;
    return parts[0];
  }

  public function getHealthbarAssetPath(raw:Bool = false):Null<String>
  {
    if (raw)
    {
      var rawPath:Null<String> = _data?.assets?.healthbar?.assetPath;
      if (rawPath == null && fallback != null) return fallback.getHealthbarAssetPath(true);
      return rawPath;
    }

    // library:path
    var parts = getHealthbarAssetPath(true)?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length == 0) return null;
    if (parts.length == 1) return getHealthbarAssetPath(true);
    return parts[1];
  }

  function getHealthbarAssetLibrary():Null<String>
  {
    // library:path
    var parts = getHealthbarAssetPath(true)?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length == 0) return null;
    if (parts.length == 1) return null;
    return parts[0];
  }

  // TODO: add anim suport for healthbar
  function buildNoteAnimations():Void {}

  public function isHealthbarAnimated():Bool
  {
    return _data.assets?.healthbar?.animated ?? false;
  }

  public function istimebarAnimated():Bool
  {
    return _data.assets?.timebar?.animated ?? false;
  }

  public function getHealthbarScale():Float
  {
    return _data.assets?.healthbar?.scale ?? 1.0;
  }

  public function getHealthbarbarOffsets():Array<Float>
  {
    return _data.assets.healthbar.data.baroffsets ?? [0, 0];
  }

  public function getHealthbarbarbgOffsets():Array<Float>
  {
    return _data.assets.healthbar.data.barbgoffsets ?? [0, 0];
  }

  public function getHealthbarspriteOffsets():Array<Float>
  {
    return _data?.assets?.healthbar?.offsets ?? [0, 0];
  }

  public function getTimebarbarOffsets():Array<Float>
  {
    return _data.assets.timebar.data.baroffsets ?? [0, 0];
  }

  public function getTimebarspriteOffsets():Array<Float>
  {
    return _data?.assets?.timebar?.offsets ?? [0, 0];
  }

  // TODO: ANIM SUPPORT
  // function fetchHealthbarAnimationData():Null<AnimationData> {}

  /**
   * Build a sprite for the given step of the countdown.
   * @param step
   * @return A `FunkinSprite`, or `null` if no graphic is available for this step.
   */
  public function buildCountdownSprite(step:Countdown.CountdownStep):Null<FunkinSprite>
  {
    var result = new FunkinSprite();

    switch (step)
    {
      case THREE:
        if (_data.assets.countdownThree == null) return fallback?.buildCountdownSprite(step);
        var assetPath = buildCountdownSpritePath(step);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.countdownThree?.scale ?? 1.0;
        result.scale.y = _data.assets.countdownThree?.scale ?? 1.0;
      case TWO:
        if (_data.assets.countdownTwo == null) return fallback?.buildCountdownSprite(step);
        var assetPath = buildCountdownSpritePath(step);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.countdownTwo?.scale ?? 1.0;
        result.scale.y = _data.assets.countdownTwo?.scale ?? 1.0;
      case ONE:
        if (_data.assets.countdownOne == null) return fallback?.buildCountdownSprite(step);
        var assetPath = buildCountdownSpritePath(step);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.countdownOne?.scale ?? 1.0;
        result.scale.y = _data.assets.countdownOne?.scale ?? 1.0;
      case GO:
        if (_data.assets.countdownGo == null) return fallback?.buildCountdownSprite(step);
        var assetPath = buildCountdownSpritePath(step);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.countdownGo?.scale ?? 1.0;
        result.scale.y = _data.assets.countdownGo?.scale ?? 1.0;
      default:
        // TODO: Do something here?
        return null;
    }

    result.scrollFactor.set(0, 0);
    result.antialiasing = !isCountdownSpritePixel(step);
    result.updateHitbox();

    return result;
  }

  function buildCountdownSpritePath(step:Countdown.CountdownStep):Null<String>
  {
    var basePath:Null<String> = null;
    switch (step)
    {
      case THREE:
        basePath = _data.assets.countdownThree?.assetPath;
      case TWO:
        basePath = _data.assets.countdownTwo?.assetPath;
      case ONE:
        basePath = _data.assets.countdownOne?.assetPath;
      case GO:
        basePath = _data.assets.countdownGo?.assetPath;
      default:
        basePath = null;
    }

    if (basePath == null) return fallback?.buildCountdownSpritePath(step);

    var parts = basePath?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length < 1) return null;
    if (parts.length == 1) return parts[0];

    return parts[1];
  }

  function buildCountdownSpriteLibrary(step:Countdown.CountdownStep):Null<String>
  {
    var basePath:Null<String> = null;
    switch (step)
    {
      case THREE:
        basePath = _data.assets.countdownThree?.assetPath;
      case TWO:
        basePath = _data.assets.countdownTwo?.assetPath;
      case ONE:
        basePath = _data.assets.countdownOne?.assetPath;
      case GO:
        basePath = _data.assets.countdownGo?.assetPath;
      default:
        basePath = null;
    }

    if (basePath == null) return fallback?.buildCountdownSpriteLibrary(step);

    var parts = basePath?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length <= 1) return null;

    return parts[0];
  }

  public function isCountdownSpritePixel(step:Countdown.CountdownStep):Bool
  {
    switch (step)
    {
      case THREE:
        var result = _data.assets.countdownThree?.isPixel;
        if (result == null && fallback != null) result = fallback.isCountdownSpritePixel(step);
        return result ?? false;
      case TWO:
        var result = _data.assets.countdownTwo?.isPixel;
        if (result == null && fallback != null) result = fallback.isCountdownSpritePixel(step);
        return result ?? false;
      case ONE:
        var result = _data.assets.countdownOne?.isPixel;
        if (result == null && fallback != null) result = fallback.isCountdownSpritePixel(step);
        return result ?? false;
      case GO:
        var result = _data.assets.countdownGo?.isPixel;
        if (result == null && fallback != null) result = fallback.isCountdownSpritePixel(step);
        return result ?? false;
      default:
        return false;
    }
  }

  public function getCountdownSpriteOffsets(step:Countdown.CountdownStep):Array<Float>
  {
    switch (step)
    {
      case THREE:
        var result = _data.assets.countdownThree?.offsets;
        if (result == null && fallback != null) result = fallback.getCountdownSpriteOffsets(step);
        return result ?? [0, 0];
      case TWO:
        var result = _data.assets.countdownTwo?.offsets;
        if (result == null && fallback != null) result = fallback.getCountdownSpriteOffsets(step);
        return result ?? [0, 0];
      case ONE:
        var result = _data.assets.countdownOne?.offsets;
        if (result == null && fallback != null) result = fallback.getCountdownSpriteOffsets(step);
        return result ?? [0, 0];
      case GO:
        var result = _data.assets.countdownGo?.offsets;
        if (result == null && fallback != null) result = fallback.getCountdownSpriteOffsets(step);
        return result ?? [0, 0];
      default:
        return [0, 0];
    }
  }

  public function getCountdownSoundPath(step:Countdown.CountdownStep, raw:Bool = false):Null<String>
  {
    trace(step);
    if (raw)
    {
      // TODO: figure out why ?. didn't work here
      var rawPath:Null<String> = switch (step)
      {
        case Countdown.CountdownStep.THREE:
          _data.assets.countdownThree?.data?.audioPath;
        case Countdown.CountdownStep.TWO:
          _data.assets.countdownTwo?.data?.audioPath;
        case Countdown.CountdownStep.ONE:
          _data.assets.countdownOne?.data?.audioPath;
        case Countdown.CountdownStep.GO:
          _data.assets.countdownGo?.data?.audioPath;
        default:
          null;
      }
      trace(rawPath);

      return (rawPath == null && fallback != null) ? fallback.getCountdownSoundPath(step, true) : rawPath;
    }

    // library:path
    var parts = getCountdownSoundPath(step, true)?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length == 0) return null;
    if (parts.length == 1) return Paths.image(parts[0]);
    trace(parts[1] + 'and' + parts[0]);
    return Paths.sound(parts[1], parts[0]);
  }

  public function buildtimmingSprite(rating:String):Null<FunkinSprite>
  {
    var result = new FunkinSprite();

    switch (rating)
    {
      case "early":
        if (_data.assets.earlyshit == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.earlyshit?.scale ?? 1.0;
        result.scale.y = _data.assets.earlyshit?.scale ?? 1.0;

      case "late":
        if (_data.assets.lateshit == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.lateshit?.scale ?? 1.0;
        result.scale.y = _data.assets.lateshit?.scale ?? 1.0;

      default:
        return null;
    }

    result.scrollFactor.set(0.2, 0.2);
    var isPixel = isJudgementSpritePixel(rating);
    result.antialiasing = !isPixel;
    result.pixelPerfectRender = isPixel;
    result.pixelPerfectPosition = isPixel;
    result.updateHitbox();

    return result;
  }

  public function buildJudgementSprite(rating:String):Null<FunkinSprite>
  {
    var result = new FunkinSprite();

    switch (rating)
    {
      case "killer":
        if (_data.assets.judgementKiller == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.judgementKiller?.scale ?? 1.0;
        result.scale.y = _data.assets.judgementKiller?.scale ?? 1.0;
      case "sick":
        if (_data.assets.judgementSick == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.judgementSick?.scale ?? 1.0;
        result.scale.y = _data.assets.judgementSick?.scale ?? 1.0;
      case "good":
        if (_data.assets.judgementGood == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.judgementGood?.scale ?? 1.0;
        result.scale.y = _data.assets.judgementGood?.scale ?? 1.0;
      case "bad":
        if (_data.assets.judgementBad == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.judgementBad?.scale ?? 1.0;
        result.scale.y = _data.assets.judgementBad?.scale ?? 1.0;
      case "shit":
        if (_data.assets.judgementShit == null) return fallback?.buildJudgementSprite(rating);
        var assetPath = buildJudgementSpritePath(rating);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.judgementShit?.scale ?? 1.0;
        result.scale.y = _data.assets.judgementShit?.scale ?? 1.0;
      default:
        return null;
    }

    result.scrollFactor.set(0.2, 0.2);
    var isPixel = isJudgementSpritePixel(rating);
    result.antialiasing = !isPixel;
    result.pixelPerfectRender = isPixel;
    result.pixelPerfectPosition = isPixel;
    result.updateHitbox();

    return result;
  }

  public function isJudgementSpritePixel(rating:String):Bool
  {
    switch (rating)
    {
      case "sick":
        var result = _data.assets.judgementSick?.isPixel;
        if (result == null && fallback != null) result = fallback.isJudgementSpritePixel(rating);
        return result ?? false;
      case "good":
        var result = _data.assets.judgementGood?.isPixel;
        if (result == null && fallback != null) result = fallback.isJudgementSpritePixel(rating);
        return result ?? false;
      case "bad":
        var result = _data.assets.judgementBad?.isPixel;
        if (result == null && fallback != null) result = fallback.isJudgementSpritePixel(rating);
        return result ?? false;
      case "GO":
        var result = _data.assets.judgementShit?.isPixel;
        if (result == null && fallback != null) result = fallback.isJudgementSpritePixel(rating);
        return result ?? false;
      default:
        return false;
    }
  }

  function buildJudgementSpritePath(rating:String):Null<String>
  {
    var basePath:Null<String> = null;
    switch (rating)
    {
      case "killer":
        basePath = _data.assets.judgementKiller?.assetPath;
      case "sick":
        basePath = _data.assets.judgementSick?.assetPath;
      case "good":
        basePath = _data.assets.judgementGood?.assetPath;
      case "bad":
        basePath = _data.assets.judgementBad?.assetPath;
      case "shit":
        basePath = _data.assets.judgementShit?.assetPath;
      default:
        basePath = null;
    }

    if (basePath == null) return fallback?.buildJudgementSpritePath(rating);

    var parts = basePath?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length < 1) return null;
    if (parts.length == 1) return parts[0];

    return parts[1];
  }

  public function gettimmingSpriteOffsets(rating:String):Array<Float>
  {
    switch (rating)
    {
      case "early":
        var result = _data.assets.earlyshit?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      case "late":
        var result = _data.assets.lateshit?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      default:
        return [0, 0];
    }
  }

  public function getJudgementSpriteOffsets(rating:String):Array<Float>
  {
    switch (rating)
    {
      case "sick":
        var result = _data.assets.judgementSick?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      case "good":
        var result = _data.assets.judgementGood?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      case "bad":
        var result = _data.assets.judgementBad?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      case "shit":
        var result = _data.assets.judgementShit?.offsets;
        if (result == null && fallback != null) result = fallback.getJudgementSpriteOffsets(rating);
        return result ?? [0, 0];
      default:
        return [0, 0];
    }
  }

  public function buildComboNumSprite(digit:Int):Null<FunkinSprite>
  {
    var result = new FunkinSprite();

    switch (digit)
    {
      case 0:
        if (_data.assets.comboNumber0 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber0?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber0?.scale ?? 1.0;
      case 1:
        if (_data.assets.comboNumber1 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber1?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber1?.scale ?? 1.0;
      case 2:
        if (_data.assets.comboNumber2 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber2?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber2?.scale ?? 1.0;
      case 3:
        if (_data.assets.comboNumber3 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber3?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber3?.scale ?? 1.0;
      case 4:
        if (_data.assets.comboNumber4 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber4?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber4?.scale ?? 1.0;
      case 5:
        if (_data.assets.comboNumber5 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber5?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber5?.scale ?? 1.0;
      case 6:
        if (_data.assets.comboNumber6 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber6?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber6?.scale ?? 1.0;
      case 7:
        if (_data.assets.comboNumber7 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber7?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber7?.scale ?? 1.0;
      case 8:
        if (_data.assets.comboNumber8 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber8?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber8?.scale ?? 1.0;
      case 9:
        if (_data.assets.comboNumber9 == null) return fallback?.buildComboNumSprite(digit);
        var assetPath = buildComboNumSpritePath(digit);
        if (assetPath == null) return null;
        result.loadTexture(assetPath);
        result.scale.x = _data.assets.comboNumber9?.scale ?? 1.0;
        result.scale.y = _data.assets.comboNumber9?.scale ?? 1.0;
      default:
        return null;
    }

    var isPixel = isComboNumSpritePixel(digit);
    result.antialiasing = !isPixel;
    result.pixelPerfectRender = isPixel;
    result.pixelPerfectPosition = isPixel;
    result.updateHitbox();

    return result;
  }

  public function isComboNumSpritePixel(digit:Int):Bool
  {
    switch (digit)
    {
      case 0:
        var result = _data.assets.comboNumber0?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 1:
        var result = _data.assets.comboNumber1?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 2:
        var result = _data.assets.comboNumber2?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 3:
        var result = _data.assets.comboNumber3?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 4:
        var result = _data.assets.comboNumber4?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 5:
        var result = _data.assets.comboNumber5?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 6:
        var result = _data.assets.comboNumber6?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 7:
        var result = _data.assets.comboNumber7?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 8:
        var result = _data.assets.comboNumber8?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      case 9:
        var result = _data.assets.comboNumber9?.isPixel;
        if (result == null && fallback != null) result = fallback.isComboNumSpritePixel(digit);
        return result ?? false;
      default:
        return false;
    }
  }

  function buildComboNumSpritePath(digit:Int):Null<String>
  {
    var basePath:Null<String> = null;
    switch (digit)
    {
      case 0:
        basePath = _data.assets.comboNumber0?.assetPath;
      case 1:
        basePath = _data.assets.comboNumber1?.assetPath;
      case 2:
        basePath = _data.assets.comboNumber2?.assetPath;
      case 3:
        basePath = _data.assets.comboNumber3?.assetPath;
      case 4:
        basePath = _data.assets.comboNumber4?.assetPath;
      case 5:
        basePath = _data.assets.comboNumber5?.assetPath;
      case 6:
        basePath = _data.assets.comboNumber6?.assetPath;
      case 7:
        basePath = _data.assets.comboNumber7?.assetPath;
      case 8:
        basePath = _data.assets.comboNumber8?.assetPath;
      case 9:
        basePath = _data.assets.comboNumber9?.assetPath;
      default:
        basePath = null;
    }

    if (basePath == null) return fallback?.buildComboNumSpritePath(digit);

    var parts = basePath?.split(Constants.LIBRARY_SEPARATOR) ?? [];
    if (parts.length < 1) return null;
    if (parts.length == 1) return parts[0];

    return parts[1];
  }

  public function getComboNumSpriteOffsets(digit:Int):Array<Float>
  {
    switch (digit)
    {
      case 0:
        var result = _data.assets.comboNumber0?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 1:
        var result = _data.assets.comboNumber1?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 2:
        var result = _data.assets.comboNumber2?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 3:
        var result = _data.assets.comboNumber3?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 4:
        var result = _data.assets.comboNumber4?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 5:
        var result = _data.assets.comboNumber5?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 6:
        var result = _data.assets.comboNumber6?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 7:
        var result = _data.assets.comboNumber7?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 8:
        var result = _data.assets.comboNumber8?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      case 9:
        var result = _data.assets.comboNumber9?.offsets;
        if (result == null && fallback != null) result = fallback.getComboNumSpriteOffsets(digit);
        return result ?? [0, 0];
      default:
        return [0, 0];
    }
  }

  public function destroy():Void {}

  public function toString():String
  {
    return 'HudStyle($id)';
  }

  static function _fetchData(id:String):HudStyleData
  {
    var result = HudStyleRegistry.instance.parseEntryDataWithMigration(id, HudStyleRegistry.instance.fetchEntryVersion(id));
    trace(result);
    if (result == null)
    {
      throw 'Could not parse hud style data for id: $id';
    }
    else
    {
      return result;
    }
  }
}
