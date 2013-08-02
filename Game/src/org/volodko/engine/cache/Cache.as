package org.volodko.engine.cache {
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.System;
import flash.utils.Dictionary;

import org.volodko.engine.CmdVO;
import org.volodko.engine.ConsoleCmd;

import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.Module;
import org.volodko.engine.MsgVO;
import org.volodko.engine.VBitmapData;
import org.volodko.engine.XMLData;

public class Cache extends Module {
    private var clips:Dictionary = new Dictionary(true);
    private var clipsChildPos:Vector.<ClipPosData> = new Vector.<ClipPosData>();
    //
    private var revertClips:Vector.<Class> = new Vector.<Class>();
    private var hideClips:Vector.<String> = new Vector.<String>();
    private var cachePosClips:Vector.<String> = new Vector.<String>();
    //
    private var clipsToCache:Vector.<Class> = new Vector.<Class>();
    private var permClipsToCache:Vector.<Class> = new Vector.<Class>();
    private var dataID:String;
    private var xmlData:XMLData;
    private var cacheDataXML:XML;
    //Temp vars
    private var currentClip:MovieClip;
    private var clipClass:Class;
    private var maxRect:Rectangle = new Rectangle();
    //
    public function Cache(dataID:String) {
        this.dataID = dataID;
        init();
    }

    private function init():void {
        xmlData = XMLData(GLB.engine.getModule(XMLData));
        cacheDataXML = xmlData.getXML(dataID);
        //
        CONFIG::debug {
            register(signalsDebug, GroupsVO.DEBUG);
        }
    }

    public function addClassToCache(className:Class):void {
        clipsToCache.push(className);
    }

    public function addPermClassToCache(className:Class):void {
        permClipsToCache.push(className);
    }

    public function addHideClipsNames(namesArray:Array):void {
        for (var i:int = 0; i < namesArray.length; i++) hideClips.push(namesArray[i]);
    }

    public function addCachePosNames(namesArray:Array):void {
        for (var i:int = 0; i < namesArray.length; i++) cachePosClips.push(namesArray[i]);
    }

    public function addRevertClipsClasses(namesArray:Array):void {
        for (var i:int = 0; i < namesArray.length; i++) revertClips.push(namesArray[i]);
    }

    public function removeAll():void {

    }

    /*
     * RetumaxRect true if has also clips to cache
     */
    public function cacheOnce():Boolean {
        if(!currentClip) {
            if(clipsToCache.length > 0) {
                clipClass = clipsToCache.pop();
                currentClip = new clipClass();
                //Cache data
                var cacheData:XMLList = cacheDataXML.clip.(@name == String(clipClass));
                //if(cacheData != undefined) { trace(clipClass+" has cache"); }
                //
                clips[clipClass] = new ClipData(maxRect.clone(), cachePosClips, String(clipClass), cacheData);
                prepareMaxRect();
                //TODO reverse clips
                return true; //Continue cache in next frame
            } else return false; //Stop cache
        } else {
            //Cache 1 frame in 1 tick
            hideHelpClips();
            clips[clipClass].addFrame(currentClip);
            currentClip.nextFrame();
            //trace(currentClip, currentClip.currentFrame);
            if(currentClip.totalFrames == currentClip.currentFrame || currentClip.currentFrame == 1) {
                currentClip = null;
            }
            return true; //Continue cache in next frame
        }
        //
        return false; //Stop cache
    }

    private function hideHelpClips():void {
        // Hide interactive objects like patience line, wish icon
        for (var j:int = 0; j < hideClips.length; ++j) {
            if (currentClip[hideClips[j]]) currentClip[hideClips[j]].visible = false;
        }
    }

    private function prepareMaxRect():void {
        var r:Rectangle;
        for (var i:int = 1; i <= currentClip.totalFrames; ++i) {
            currentClip.gotoAndStop(i);
            r = currentClip.getRect(currentClip);
            if (r.x < maxRect.x) maxRect.x = r.x;
            if (r.y < maxRect.y) maxRect.y = r.y;
            if (r.width > maxRect.width) maxRect.width = r.width;
            if (r.height > maxRect.height) maxRect.height = r.height;
            //trace(r);
        }
        currentClip.gotoAndStop(1);
    }

    private function cacheClip(className:Class):void {
        var needReverse:Boolean = checkReverse(currentClip, revertClips);
        //For reverse
        if (needReverse) ClipData(clips[className]).addReverseData();
        //-------------------- Get list of frames as static, for development --------------
        /* trace("------------------ class " + className + " ---------------------------");
         for (var k:int = 0; k < ClipData(clips[className]).framesTitles.length; k++)
         {
         var name:String = ClipData(clips[className]).framesTitles[k];
         trace("static public const TYPE_"+name.toUpperCase()+":String = \""+name+"\"");
         }
         */
    }

    private function checkReverse(currentClipLoc:MovieClip, revertClipsLoc:Vector.<Class>):Boolean {
        for (var i:int = 0; i < revertClipsLoc.length; ++i) {
            if (currentClipLoc is revertClipsLoc[i]) return true;
        }
        return false;
    }

    //
    public function getClip(originClassName:Class):ClipData {
        return clips[originClassName];
    }

    // For cached positions
    public function cachePos(clipClass:Class, chName:String):void {
        var tmpClassName:String = String(clipClass);
        if (!clipsChildPos) clipsChildPos = new Vector.<ClipPosData>();
        var tmpClipPosData:ClipPosData;
        if (!hasClass(tmpClassName)) {
            tmpClipPosData = new ClipPosData(tmpClassName);
            clipsChildPos.push(tmpClipPosData);
        } else {
            tmpClipPosData = getClipPosData(tmpClassName);
        }
        if (!tmpClipPosData.hasName(chName)) {
            var clip:MovieClip = new clipClass();
            tmpClipPosData.addName(clip, chName);
        }
    }

    public function getClipPosDataStr(clipClass:Class):ClipPosData {
        return getClipPosData(String(clipClass));
    }

    private function getClipPosData(tmpClassName:String):ClipPosData {
        for (var i:int = 0; i < clipsChildPos.length; ++i) {
            if (clipsChildPos[i].className == tmpClassName) return clipsChildPos[i];
        }
        return null;
    }

    private function hasClass(tmpClassName:String):Boolean {
        for (var i:int = 0; i < clipsChildPos.length; ++i) {
            if (clipsChildPos[i].className == tmpClassName) return true;
        }
        return false;
    }

    private function signalsDebug(msg:String,  data:Object):void {
        switch(msg) {
            //Commands
            case MsgVO.CONSOLE_COMMAND:
                switch(ConsoleCmd(data).commandName) {
                    case CmdVO.CACHE_CLEAR:
                            //TODO
                        break;
                    case CmdVO.CACHE_GEN:
                            generateXMLData();
                        break;
                }
                break;
        }
    }

    private function generateXMLData():void {
        var dataStr:String = '<?xml version="1.0" encoding="UTF-8"?>' + "\n";
        dataStr += "<data>\n";
        //
        for(var val:* in clips){
            var cd:ClipData = ClipData(clips[val]);
            var bdStr:Array = []; var physStr:Array = [];
            for (var i:int = 0; i < cd.framesBD.length; i++)
            {
                if (i > 0) {
                    //Bitmap
                    for (var j:int = 0; j < i; ++j)
                    {
                        if (cd.framesBD[i].compare(cd.framesBD[j]) === 0) {
                            bdStr.push(i+","+j);
                            break;
                        }
                    }
                    //Physic
                    //if (cd.physicBD[i] == cd.physicBD[i - 1]) physStr.push(i);
                }
            }
            dataStr += '	<clip name="'+val+'" sameBitmap="'+bdStr.join("|")+'" physic="'+physStr.join(",")+'" />'+"\n";
        }
        dataStr += "</data>\n";
        //
        System.setClipboard(dataStr);
        //
        CONFIG::debug { dispatch(MsgVO.LOG, "Generated xml data copied to clipboard !", GroupsVO.DEBUG); }
        //
    }

    //----------------------------- Help Rasterizing -----------------------
    /* static private function getBitmap(currentClip:DisplayObject):VBitmapData {
        if (currentClip.width > 0 && currentClip.height > 0) {
            var m:Matrix = new Matrix();
            var r:Rectangle = currentClip.getRect(currentClip);
            r = normlizeRect(r);
            m.translate(-r.x, -r.y);
            m.scale(currentClip.scaleX, currentClip.scaleY);
            var tmpBD:VBitmapData = new VBitmapData(r.width, r.height, true, 0x000000);
            tmpBD.draw(currentClip, m, null, null, null, true);
            return tmpBD;
        } else return null;
    }

    //
    static private function normlizeRect(rLoc:Rectangle):Rectangle {
        rLoc.x = int(rLoc.x);
        rLoc.y = int(rLoc.y);
        rLoc.width = int(rLoc.width);
        rLoc.height = int(rLoc.height);
        return rLoc;
    }

    //
    static public function rasterizePart(tmpChild:DisplayObject, mouseEnabled:Boolean = false):Sprite {
        if (tmpChild.parent) {
            var tmpB:Bitmap = new Bitmap(getBitmap(tmpChild));
            tmpB.smoothing = true;
            var tmpR:Rectangle = tmpChild.getRect(tmpChild);
            //trace(tmpR);
            //tmpB.x = tmpChild.x; tmpB.y = tmpChild.y;
            tmpB.x = tmpR.x;
            tmpB.y = tmpR.y;
            var tmpS:Sprite = new Sprite();
            tmpS.addChild(tmpB);
            tmpS.x = tmpChild.x;
            tmpS.y = tmpChild.y;
            if (!mouseEnabled) tmpS.mouseChildren = tmpS.mouseEnabled = false;
            tmpChild.parent.addChild(tmpS);
            return tmpS;
            //tmpChild.parent.removeChild(tmpChild);
        } else {
            return null;
            trace("Error: No where add");
        }
    }
        */
}

}