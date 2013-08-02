package org.volodko.engine {
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;

import nape.geom.GeomPolyList;

import org.volodko.engine.cache.Cache;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.cache.ClipData;
import org.volodko.engine.utils.LoDMath;

public class VSprite extends Sprite {
    //
    private var baseClass:Class;
    private var graphic:Bitmap;
    private var graphicData:ClipData;
    private var framesBD:Vector.<VBitmapData>;
    private var _currFrame:int = 0;
    private var numFrames:int = 0;
    private var tmpFrame:Number = 0;
    private var elapsedFrames:int = 0;
    private var spritesFPS:Number = 0;
    private var lastLabel:String;
    private var isPlaying:Boolean = true;
    //
    private var debugTxt:TextField;
    //
    private var orClip:DisplayObject;
    //
    private var clone:Boolean;
    //
    private var slowed:Boolean = false;
    //
    public function VSprite(baseClass:Class, clone:Boolean = false) {
        super();
        this.baseClass = baseClass;
        this.clone = clone;
        init();
    }

    private function init():void {

        graphicData = Cache(GLB.engine.getModule(Cache)).getClip(baseClass);
        if (!graphicData) trace("VSprite error: " + graphicData);
        //
        setDefaultFPS();
        graphic = new Bitmap(null, "auto", true);
        graphic.x = graphicData.rn.x;
        graphic.y = graphicData.rn.y;
        if (clone) prepareFramesBD();
        else framesBD = graphicData.framesBD;
        numFrames = framesBD.length;
        addChild(graphic);
        render();
        //
        //NNLG.signals.add(signalListener);
        //
        //trace("cached fr "+framesBD.length);
    }

    private function prepareFramesBD():void {
        framesBD = new Vector.<VBitmapData>();
        for (var i:int = 0; i < graphicData.framesBD.length; ++i) {
            framesBD.push(graphicData.framesBD[i].cloneBD());
        }
    }

    private function drawDebug():void {
        /*
         if (Glb.debug) {
         if (!debugTxt) {
         debugTxt = new TextField();
         addChild(debugTxt);
         }
         debugTxt.text = String(currFrame);
         var tmpR:Rectangle = graphic.getRect(this); //trace(tmpR, graphic.width, graphic.height);
         graphics.clear();
         graphics.beginFill(0xff00ff, 0.6);
         graphics.drawRect(tmpR.x, tmpR.y, tmpR.width, tmpR.height);
         graphics.endFill();
         graphics.beginFill(0x0000ff, 1);
         graphics.drawRect(0,0, 3, 3);
         graphics.endFill();
         graphic.alpha = 0.5;
         } */
    }

    public function update():void {
        currFrame = int(tmpFrame);
        if (isPlaying) {
            nextFrame();
            render();
        }
        //NNLG.signals.dispatch("log","VSprite param "+currFrame+" "+getLabel());
    }

    public function nextFrame():void {
        tmpFrame += GLB.stage.frameRate / spritesFPS;
        //currFrame++;
        if (tmpFrame >= numFrames) tmpFrame = 0;
        //render();
    }

    private function render():void {
        if (framesBD[currFrame]) {
            graphic.bitmapData = framesBD[currFrame];
            graphic.x = int(graphicData.framesPos[currFrame].x);
            graphic.y = int(graphicData.framesPos[currFrame].y);
            //graphic.smoothing = Hlp.smoothOn;
            //drawDebug();
        }
    }

    public function goAndPlay(frame:Object):void {
        if (frame is int) {
            currFrame = (int(frame) - 1 >= 0) ? int(frame) - 1 : 0;
        } else if (frame is String) {
            currFrame = getFrameFromString(String(frame));
        }
        tmpFrame = currFrame;
        isPlaying = true;
        render();
    }

    public function goAndStop(frame:Object):void {
        if (frame is int) {
            currFrame = (int(frame) - 1 >= 0) ? int(frame) - 1 : 0;
        } else if (frame is String) {
            currFrame = getFrameFromString(String(frame));
            lastLabel = String(frame);
        }
        tmpFrame = currFrame;
        isPlaying = false;
        render();
    }

    public function getLastlabel():String {
        return lastLabel;
    }

    public function getGraphic():Bitmap {
        return graphic;
    }

    public function getLabel():String {
        return graphicData.framesTitles[currFrame];
    }

    public function getAllLabels():Vector.<String> {
        return graphicData.framesTitles;
    }

    public function hasLabel(labelName:String):Boolean {
        if (graphicData.framesTitles.indexOf(labelName) >= 0) return true;
        else return false;
    }

    private function getFrameFromString(frame:String):int {
        for (var i:int = 0; i < graphicData.framesPos.length; ++i) {
            if (graphicData.framesTitles[i] == frame) {
                //trace("frame "+i);
                return i;
            }
        }
        return 0; // No title
    }

    public function getChild(childName:String):DisplayObject {
        //Lazy init && little spike
        if (!orClip) orClip = new baseClass();
        MovieClip(orClip).gotoAndStop(currFrame);
        if (orClip[childName]) {
            if (!contains(orClip[childName])) addChild(orClip[childName]);
            return orClip[childName];
        }
        return null; //Error
    }

    public function getChildPos(childName:String):Point {
        for (var i:int = 0; i < graphicData.framesChild[currFrame].length; ++i) {
            var diso:ChildData = graphicData.framesChild[currFrame][i];
            if (diso.name == childName) return new Point(diso.x, diso.y);
        }
        //No data
        trace("ERROR: No cache clip position ! Clip: " + baseClass + " Name: " + childName);
        return new Point();
    }

    public function getChildRadius(childName:String):Number {
        var ret:Number = 0;
        var have:Boolean = false;
        for (var i:int = 0; i < graphicData.framesChild[currFrame].length; ++i) {
            var diso:ChildData = graphicData.framesChild[currFrame][i];
            if (diso.name == childName) {
                return diso.width / 2;
            }
        }
        //No data
        trace("ERROR: No cache clip radius ! Name: " + childName);
        return ret;
    }

    /*
     * Return In degrees
     */
    public function getChildRotation(childName:String, radians:Boolean = false):Number {
        var ret:Number = 0;
        var have:Boolean = false;
        for (var i:int = 0; i < graphicData.framesChild[currFrame].length; ++i) {
            var diso:ChildData = graphicData.framesChild[currFrame][i];
            if (diso.name == childName) {
                ret = diso.rotation;
                have = true;
            }
        }
        //No data
        if (!have) trace("ERROR: No cache clip rotation ! Name: " + childName);
        if (radians) ret = LoDMath.degreesToRadians(ret);
        return ret;
    }

    public function getClipData():ClipData {
        return graphicData;
    }

    public function getChildData(childName:String):ChildData {
        for (var i:int = 0; i < graphicData.framesChild[currFrame].length; ++i) {
            var diso:ChildData = graphicData.framesChild[currFrame][i];
            if (diso.name == childName) return diso;
        }
        return null;
    }

    public function haveChild(childName:String):Boolean {
        for (var i:int = 0; i < graphicData.framesChild[currFrame].length; ++i) {
            var diso:ChildData = graphicData.framesChild[currFrame][i];
            if (diso.name == childName) return true;
        }
        return false;
    }

    public function getBD():VBitmapData {
        return framesBD[currFrame];
    }

    public function getPoint():Point {
        return graphicData.framesPos[currFrame];
    }

    public function getPhysicPerimeter():GeomPolyList {
        return graphicData.physicBD[currFrame];
    }

    public function setFPS(val:Number):void {
        spritesFPS = val;
    }

    public function setDefaultFPS():void {
        spritesFPS = GLB.stage.frameRate;
    }

    /* public function getChildPos(childName:String):Point
     {
     for (var i:int = 0; i < graphicData.framesObjects[currFrame].length; ++i)
     {
     var diso:DisplayObject = graphicData.framesObjects[currFrame][i];
     if (diso.name == childName) return new Point(diso.x, diso.y);
     }
     //No data
     return new Point();
     } */
    public function get currFrame():int {
        return _currFrame;
    }

    public function set currFrame(value:int):void {
        if (value < 0 || value >= framesBD.length) value = 0;
        _currFrame = value;
    }

    public function totalFrames():int {
        return framesBD.length;
    }

    //------------- Painting features --------
    public function draw(bdToCopy:VBitmapData, pos:Point, rotation:Number = 0, rotMargin:Point = null):void {
        if (rotation != 0) {
            //Draw
            var matrix:Matrix = new Matrix();
            if (rotMargin) matrix.translate(rotMargin.x, rotMargin.y);
            matrix.rotate(LoDMath.degreesToRadians(rotation));
            if (rotMargin) matrix.translate(-rotMargin.x, -rotMargin.y);
            matrix.translate(pos.x, pos.y);
            framesBD[currFrame].draw(bdToCopy, matrix, null, null, null, true);
        } else {
            //Copy pixels
            framesBD[currFrame].copyPixels(bdToCopy, bdToCopy.rect, pos, null, null, true);
        }
    }

    //------------- For pause ----------------
    public function stop():void {
        isPlaying = false;
    }

    public function play():void {
        isPlaying = true;
    }

    public function isPlay():Boolean {
        return isPlaying;
    }

    /* ------------------------------------- Signals listener --------------------------------------- */
    /* public function signalListener(msg:String, data:Object):void
     {
     switch(msg) {
     case Msg.STATE_END:
     NNLG.signals.remove(signalListener);
     break;
     //
     case Msg.SLOW_TIME:
     slowed = true;
     setFPS(getDefaultFPS());
     break;
     case Msg.NORM_TIME:
     slowed = false;
     setFPS(getDefaultFPS());
     break;
     }
     }         */

}

}