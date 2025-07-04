package funkin.play.notes;

import funkin.play.notes.notestyle.NoteStyle;
import funkin.play.notes.NoteDirection;
import funkin.data.song.SongData.SongNoteData;
import flixel.util.FlxDirectionFlags;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import funkin.ui.options.PreferencesMenu;

/**
 * This is based heavily on the `FlxStrip` class. It uses `drawTriangles()` to clip a sustain note
 * trail at a certain time.
 * The whole `FlxGraphic` is used as a texture map. See the `NOTE_hold_assets.fla` file for specifics
 * on how it should be constructed.
 *
 * @author MtH
 */
class SustainTrail extends FlxSprite
{
  /**
   * The triangles corresponding to the hold, followed by the endcap.
   * `top left, top right, bottom left`
   * `top left, bottom left, bottom right`
   */
  static final TRIANGLE_VERTEX_INDICES:Array<Int> = [0, 1, 2, 1, 2, 3, 4, 5, 6, 5, 6, 7];

  public var strumTime:Float = 0; // millis
  public var noteDirection:NoteDirection = 0;
  public var sustainLength(default, set):Float = 0; // millis
  public var fullSustainLength:Float = 0;
  public var noteData:Null<SongNoteData>;
  public var parentStrumline:Strumline;

  public var cover:NoteHoldCover = null;

  /**
   * Set to `true` if the user hit the note and is currently holding the sustain.
   * Should display associated effects.
   */
  public var hitNote:Bool = false;

  /**
   * Set to `true` if the user missed the note or released the sustain.
   * Should make the trail transparent.
   */
  public var missedNote:Bool = false;

  /**
   * Set to `true` after handling additional logic for missing notes.
   */
  public var handledMiss:Bool = false;

  // maybe BlendMode.MULTIPLY if missed somehow, drawTriangles does not support!

  /**
   * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
   */
  public var vertices:DrawData<Float> = new DrawData<Float>();

  /**
   * A `Vector` of integers or indexes, where every three indexes define a triangle.
   */
  public var indices:DrawData<Int> = new DrawData<Int>();

  /**
   * A `Vector` of normalized coordinates used to apply texture mapping.
   */
  public var uvtData:DrawData<Float> = new DrawData<Float>();

  private var processedGraphic:FlxGraphic;

  private var zoom:Float = 1;

  /**
   * What part of the trail's end actually represents the end of the note.
   * This can be used to have a little bit sticking out.
   */
  public var endOffset:Float = 0.5; // 0.73 is roughly the bottom of the sprite in the normal graphic!

  /**
   * At what point the bottom for the trail's end should be clipped off.
   * Used in cases where there's an extra bit of the graphic on the bottom to avoid antialiasing issues with overflow.
   */
  public var bottomClip:Float = 0.9;

  /**
   * Whether the note will recieve custom vertex data
   */
  public var customVertexData:Bool = false;

  public var isPixel:Bool;

  /**
   * Offsets the position of the SustainTrail.
   */
  public var offsets:Array<Float> = [0, 0];

  var graphicWidth:Float = 0;
  var graphicHeight:Float = 0;

  /**
   * Normally you would take strumTime:Float, noteData:Int, sustainLength:Float, parentNote:Note (?)
   * @param NoteData
   * @param SustainLength Length in milliseconds.
   * @param fileName
   */
  public function new(noteDirection:NoteDirection, sustainLength:Float, noteStyle:NoteStyle)
  {
    super(0, 0, noteStyle.getHoldNoteAssetPath());

    antialiasing = true;

    this.isPixel = noteStyle.isHoldNotePixel();
    if (isPixel)
    {
      endOffset = bottomClip = 1;
      antialiasing = false;
    }
    zoom *= noteStyle.getHoldNoteScale();
    offsets = noteStyle.getHoldNoteOffsets();

    // BASIC SETUP
    this.sustainLength = sustainLength;
    this.fullSustainLength = sustainLength;
    this.noteDirection = noteDirection;

    zoom *= 0.7;

    // CALCULATE SIZE
    graphicWidth = graphic.width / 8 * zoom; // amount of notes * 2
    graphicHeight = sustainHeight(sustainLength, parentStrumline?.scrollSpeed ?? 1.0);
    // instead of scrollSpeed, PlayState.SONG.speed

    flipY = Preferences.downscroll;

    // alpha = 0.6;

    // calls updateColorTransform(), which initializes processedGraphic!
    updateColorTransform();

    updateClipping();
    setIndices(TRIANGLE_VERTEX_INDICES);
    this.active = true; // This NEEDS to be true for the note to be drawn!
  }

  /**
   * Sets the indices for the triangles.
   * @param indices The indices to set.
   */
  public function setIndices(indices:Array<Int>):Void
  {
    if (this.indices.length == indices.length)
    {
      for (i in 0...indices.length)
      {
        this.indices[i] = indices[i];
      }
    }
    else
    {
      this.indices = new DrawData<Int>(indices.length, false, indices);
    }
  }

  /**
   * Sets the vertices for the triangles.
   * @param vertices The vertices to set.
   */
  public function setVertices(vertices:Array<Float>):Void
  {
    if (this.vertices.length == vertices.length)
    {
      for (i in 0...vertices.length)
      {
        this.vertices[i] = vertices[i];
      }
    }
    else
    {
      this.vertices = new DrawData<Float>(vertices.length, false, vertices);
    }
  }

  /**
   * Sets the UV data for the triangles.
   * @param uvtData The UV data to set.
   */
  public function setUVTData(uvtData:Array<Float>):Void
  {
    if (this.uvtData.length == uvtData.length)
    {
      for (i in 0...uvtData.length)
      {
        this.uvtData[i] = uvtData[i];
      }
    }
    else
    {
      this.uvtData = new DrawData<Float>(uvtData.length, false, uvtData);
    }
  }

  override function getScreenPosition(?result:flixel.math.FlxPoint, ?camera:flixel.FlxCamera):flixel.math.FlxPoint
  {
    var output = super.getScreenPosition(result, camera);
    output.x += offsets[0];
    output.y += offsets[1];
    return output;
  }

  function getBaseScrollSpeed():Float
  {
    return (PlayState.instance?.currentChart?.scrollSpeed ?? 1.0);
  }

  var previousScrollSpeed:Float = 1;

  override function update(elapsed)
  {
    super.update(elapsed);
    if (previousScrollSpeed != (parentStrumline?.scrollSpeed ?? 1.0))
    {
      triggerRedraw();
    }
    previousScrollSpeed = parentStrumline?.scrollSpeed ?? 1.0;
    alpha = 0.6;
  }

  /**
   * Calculates height of a sustain note for a given length (milliseconds) and scroll speed.
   * @param	susLength	The length of the sustain note in milliseconds.
   * @param	scroll		The current scroll speed.
   */
  public static inline function sustainHeight(susLength:Float, scroll:Float)
  {
    return (susLength * 0.45 * scroll);
  }

  function set_sustainLength(s:Float):Float
  {
    if (s < 0.0) s = 0.0;

    if (sustainLength == s) return s;
    this.sustainLength = s;
    triggerRedraw();
    return this.sustainLength;
  }

  function triggerRedraw()
  {
    graphicHeight = sustainHeight(sustainLength, parentStrumline?.scrollSpeed ?? 1.0);
    updateClipping();
    updateHitbox();
  }

  public override function updateHitbox():Void
  {
    width = graphicWidth;
    height = graphicHeight;
    offset.set(0, 0);
    origin.set(width * 0.5, height * 0.5);
  }

  /**
   * Sets up new vertex and UV data to clip the trail.
   * If flipY is true, top and bottom bounds swap places.
   * @param songTime	The time to clip the note at, in milliseconds.
   */
  public function updateClipping(songTime:Float = 0):Void
  {
    var clipHeight:Float = FlxMath.bound(sustainHeight(sustainLength - (songTime - strumTime), parentStrumline?.scrollSpeed ?? 1.0), 0, graphicHeight);
    if (clipHeight <= 0.1)
    {
      visible = false;
      return;
    }
    else
    {
      visible = true;
    }

    /**
     * no idea why these used fucking math for the array. but changed to their corect numbers for modcharting...eventualy
     */

    var bottomHeight:Float = graphic.height * zoom * endOffset;
    var partHeight:Float = clipHeight - bottomHeight;

    // ===HOLD VERTICES==
    // Top left
    vertices[0] = 0.0; // Inline with left side
    vertices[1] = flipY ? clipHeight : graphicHeight - clipHeight;

    // Top right
    vertices[2] = graphicWidth;
    vertices[3] = vertices[1]; // Inline with top left vertex

    // Bottom left
    vertices[4] = 0.0; // Inline with left side
    vertices[5] = if (partHeight > 0)
    {
      // flipY makes the sustain render upside down.
      flipY ? 0.0 + bottomHeight : vertices[1] + partHeight;
    }
    else
    {
      vertices[1]; // Inline with top left vertex (no partHeight available)
    }

    // Bottom right
    vertices[6] = graphicWidth;
    vertices[7] = vertices[5]; // Inline with bottom left vertex

    // ===HOLD UVs===

    // The UVs are a bit more complicated.
    // UV coordinates are normalized, so they range from 0 to 1.
    // We are expecting an image containing 8 horizontal segments, each representing a different colored hold note followed by its end cap.

    uvtData[0] = 1 / 4 * (noteDirection % 4); // 0%/25%/50%/75% of the way through the image
    uvtData[1] = (-partHeight) / graphic.height / zoom; // top bound
    // Top left

    // Top right
    uvtData[2] = uvtData[0] + 1 / 8; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left)
    uvtData[3] = uvtData[1]; // top bound

    // Bottom left
    uvtData[4] = uvtData[0]; // 0%/25%/50%/75% of the way through the image
    uvtData[5] = 0.0; // bottom bound

    // Bottom right
    uvtData[6] = uvtData[2]; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left)
    uvtData[7] = uvtData[5]; // bottom bound

    // === END CAP VERTICES ===
    // Top left
    vertices[8] = vertices[4]; // Inline with bottom left vertex of hold
    vertices[9] = vertices[5]; // Inline with bottom left vertex of hold

    // Top right
    vertices[10] = vertices[6]; // Inline with bottom right vertex of hold
    vertices[11] = vertices[7]; // Inline with bottom right vertex of hold

    // Bottom left
    vertices[12] = vertices[4]; // Inline with left side
    vertices[13] = flipY ? (graphic.height * (-bottomClip + endOffset) * zoom) : (graphicHeight + graphic.height * (bottomClip - endOffset) * zoom);

    // Bottom right
    vertices[14] = vertices[6]; // Inline with right side
    vertices[15] = vertices[12 + 1]; // Inline with bottom of end cap

    // === END CAP UVs ===
    // Top left
    uvtData[8] = uvtData[4] + 1 / 8; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left of hold)
    uvtData[9] = if (partHeight > 0)
    {
      0;
    }
    else
    {
      (bottomHeight - clipHeight) / zoom / graphic.height;
    };

    // Top right
    uvtData[10] = uvtData[8] + 1 / 8; // 25%/50%/75%/100% of the way through the image (1/8th past the top left of cap)
    uvtData[11] = uvtData[9]; // top bound

    // Bottom left
    uvtData[12] = uvtData[8]; // 12.5%/37.5%/62.5%/87.5% of the way through the image (1/8th past the top left of hold)
    uvtData[13] = bottomClip; // bottom bound

    // Bottom right
    uvtData[14] = uvtData[10]; // 25%/50%/75%/100% of the way through the image (1/8th past the top left of cap)
    uvtData[15] = uvtData[13]; // bottom bound
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (alpha == 0 || graphic == null || vertices == null) return;

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      getScreenPosition(_point, camera).subtractPoint(offset);
      camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing, colorTransform, shader);
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  public override function kill():Void
  {
    super.kill();

    strumTime = 0;
    noteDirection = 0;
    sustainLength = 0;
    fullSustainLength = 0;
    noteData = null;

    hitNote = false;
    missedNote = false;
  }

  public override function revive():Void
  {
    super.revive();

    strumTime = 0;
    noteDirection = 0;
    sustainLength = 0;
    fullSustainLength = 0;
    noteData = null;

    hitNote = false;
    missedNote = false;
    handledMiss = false;
  }

  override public function destroy():Void
  {
    vertices = null;
    indices = null;
    uvtData = null;
    processedGraphic.destroy();

    super.destroy();
  }

  override function updateColorTransform():Void
  {
    super.updateColorTransform();
    if (processedGraphic != null) processedGraphic.destroy();
    processedGraphic = FlxGraphic.fromGraphic(graphic, true);
    processedGraphic.bitmap.colorTransform(processedGraphic.bitmap.rect, colorTransform);
  }
}
