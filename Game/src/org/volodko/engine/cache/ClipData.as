package org.volodko.engine.cache {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;

import org.volodko.engine.VBitmapData;
import org.volodko.engine.components.physic.PhysicVO;

public class ClipData {
    //
    public var physicBD:Vector.<GeomPolyList>;
    public var framesBD:Vector.<VBitmapData>;
    public var framesPos:Vector.<Point>;
    public var framesTitles:Vector.<String>;
    public var framesObjects:Vector.<Vector.<DisplayObject>>;
    public var framesChild:Vector.<Vector.<ChildData>>;
    //
    public var rn:Rectangle;
    private var tmpP:Point;
    private var rectPos:Point;
    private var cachePosClips:Vector.<String>;
    private var className:String;
    //For physic
    private var currentPhysicBitmap:VBitmapData;
    private var oldPhysicBitmap:VBitmapData;
    //For same frames
    private var sameBD:Array;
    private var physicCached:Boolean = false;
    //
    private var xmlData:XMLList;
    //
    public function ClipData(rnLoc:Rectangle, cachePosLoc:Vector.<String>, classNameLoc:String, xmlDataLoc:XMLList = null) {
        rn = rnLoc;
        cachePosClips = cachePosLoc;
        className = classNameLoc;
        xmlData = xmlDataLoc;
        rn = normlizeRect(rn);
        tmpP = new Point();
        initSameData();
        //trace(rn);
        physicBD = new Vector.<GeomPolyList>();
        framesBD = new Vector.<VBitmapData>();
        framesPos = new Vector.<Point>();
        framesTitles = new Vector.<String>();
        framesObjects = new Vector.<Vector.<DisplayObject>>();
        framesChild = new Vector.<Vector.<ChildData>>();
    }

    private function initSameData():void {
        //
        sameBD = [];
        //Same bitmaps
        if (xmlData.@sameBitmap != undefined) {
            sameBD = String(xmlData.@sameBitmap).split("|");
        }
        //Physic points cache
        if (xmlData.@physic != undefined) {
            //
            //physicCached = true;
        }
    }

    public function addFrame(fromMC:MovieClip, addTitle:String = ""):void {
        if (!physicCached) physicBD.push(getPhysicPoints(fromMC));
        framesBD.push(getBitmap(fromMC));
        framesPos.push(getPos(fromMC));
        framesTitles.push(getTitle(fromMC) + addTitle);
        //framesObjects.push(getObjects(fromMC));
        framesChild.push(getChild(fromMC));
    }

    private function getPhysicPoints(fromMC:MovieClip):GeomPolyList {
        var retList:GeomPolyList = new GeomPolyList();
        //
        for (var i:int = 0; i < fromMC.numChildren; i++) {
            var tmpChild:DisplayObject = fromMC.getChildAt(i);
            if (tmpChild.name == PhysicVO.PHYSIC_OBJECT_NAME) {
                oldPhysicBitmap = currentPhysicBitmap;
                currentPhysicBitmap = getBitmap(tmpChild, true);
                //Compare with previous
                if (physicBD.length - 1 >= 0 && physicBD[physicBD.length - 1]) {
                    if (oldPhysicBitmap && oldPhysicBitmap.compare(currentPhysicBitmap) === 0) {
                        //trace("the same physic data");
                        return physicBD[physicBD.length - 1];
                    }
                }
                //Parse
                var gpl:GeomPolyList = MarchingSquares.run(MarchingSquaresFunc, new AABB(0, 0, currentPhysicBitmap.width, currentPhysicBitmap.height), new Vec2(4, 4), 1 /*, new Vec2(50,50)*/);
                for (var j:int = 0; j < gpl.length; j++) {
                    var gp:GeomPoly = gpl.at(j);
                    gp = gp.simplify(2);
                    var glpt:GeomPolyList = gp.convex_decomposition();
                    for (var k:int = 0; k < glpt.length; k++) {
                        retList.push(glpt.at(k));
                    }
                }
                //trace(fromMC, gpl.length);
                return retList;
            }
        }
        return null;
    }

    public function addReverseData():void {
        if (!physicBD) return; //Error
        var totalFramesRev:int = physicBD.length;
        //
        for (var i:int = 0; i < totalFramesRev; ++i) {
            var frameTitle:String = framesTitles[i];
            framesTitles[i] = frameTitle + "_right";
            framesTitles.push(frameTitle + "_left");

            physicBD.push(physicBD[i]);
            //physicBD.push(getReversePhysic(physicBD[i])); //TODO
            framesBD.push(getReverseBD(framesBD[i]));
            framesPos.push(getReversePos(i));
            framesObjects.push(framesObjects[i]);

            //----- add ReverseChildPos, Magic !!!
            var addVec:Vector.<ChildData> = new Vector.<ChildData>();
            for (var ii:int = 0; ii < framesChild[i].length; ++ii) {
                var newChildPos:ChildData = getReverseChildPos(framesChild[i][ii].clone());
                addVec.push(newChildPos);
            }
            framesChild.push(addVec);

        }
    }

    // For reversed
    private function getReversePhysic(polyList:GeomPolyList):void {
        for (var i:int = 0; i < polyList.length; ++i) {
        }
    }

    private function getReverseBD(orBD:VBitmapData):VBitmapData {
        if (!orBD) {
            trace("Error: No good bitmap fo reverse");
            return null;
        }
        var mirrorMatrix:Matrix = new Matrix(-1, 0, 0, 1, orBD.width, 0);
        var imageMirror:VBitmapData = new VBitmapData(orBD.width, orBD.height, true, 0x00000000);
        imageMirror.draw(orBD, mirrorMatrix, null, null, null, true);
        //image.copyPixels( imageMirror, new Rectangle( 0, 0, orBD.width, orBD.height ), new Point( orBD.width, 0 ) );
        return imageMirror;
    }

    private function getReversePos(index:int):Point {
        var bd:VBitmapData = framesBD[index];
        var bdWidth:int = 0;
        if (bd) bdWidth = bd.width;
        var p:Point = framesPos[index];
        return new Point(-p.x - bdWidth, p.y);
    }

    private function getReverseChildPos(orChildPos:ChildData):ChildData {
        orChildPos.x = -orChildPos.x;
        orChildPos.rotation = -orChildPos.rotation;
        return orChildPos;
    }

    // Getters
    private function getPos(fromMC:MovieClip):Point {
        var tmpR:Rectangle = fromMC.getRect(fromMC);
        if (rectPos != null) {
            tmpR.x += rectPos.x;
            tmpR.y += rectPos.y;
        }
        return new Point(tmpR.x, tmpR.y);
    }

    private function getObjects(fromMC:MovieClip):Vector.<DisplayObject> {
        var retArray:Vector.<DisplayObject> = new Vector.<DisplayObject>();
        for (var i:int = 0; i < fromMC.numChildren; ++i) {
            var tmpChild:DisplayObject = fromMC.getChildAt(i);
            retArray.push(tmpChild);
        }
        return retArray;
    }

    private function getChild(fromMC:MovieClip):Vector.<ChildData> {
        //if(NNLG.signals) NNLG.signals.dispatch("log_trace", cachePosClips);
        var retArrayChild:Vector.<ChildData> = new Vector.<ChildData>();
        for (var i:int = 0; i < fromMC.numChildren; ++i) {
            var tmpChild:DisplayObject = fromMC.getChildAt(i);
            for (var j:int = 0; j < cachePosClips.length; ++j) {
                if (tmpChild.name == cachePosClips[j]) {
                    retArrayChild.push(new ChildData(tmpChild.name, tmpChild.x, tmpChild.y, tmpChild.width, tmpChild.height, tmpChild.rotation));
                }
            }
        }
        return retArrayChild;
    }

    private function getTitle(fromMC:MovieClip):String {
        return fromMC.currentLabel;
    }

    // Helpers
    private function MarchingSquaresFunc(x:Number, y:Number):Number {
        return 0x80 - (currentPhysicBitmap.getPixel32(Std._int(x), Std._int(y)) >>> 24);
    }

    private function normlizeRect(rLoc:Rectangle):Rectangle {
        rLoc.x = int(rLoc.x);
        rLoc.y = int(rLoc.y);
        rLoc.width = int(rLoc.width);
        rLoc.height = int(rLoc.height);
        return rLoc;
    }

    //Speed up
    private function haveSameBitmap(frame:int):int {
        for (var i:int = 0; i < sameBD.length; ++i) {
            var sameTmp:Array = sameBD[i].split(",");
            if (int(sameTmp[0]) == frame) return int(sameTmp[1])
        }
        return -1;
    }

    // Help Rasterizing
    private function getBitmap(originClip:DisplayObject, forPhysic:Boolean = false):VBitmapData {
        if (framesBD.length > 1) {
            var sameFrame:int = haveSameBitmap(framesBD.length);
            if (sameFrame >= 0) {
                //trace("cached bitmap data "+originClip);
                return framesBD[sameFrame];
            }
        }
        if (originClip.width > 0 && originClip.height > 0) {
            var m:Matrix = new Matrix();
            var r:Rectangle = originClip.getRect(originClip);
            r = normlizeRect(r);
            m.translate(-r.x, -r.y);
            m.scale(originClip.scaleX, originClip.scaleY);
            var tmpBD:VBitmapData = new VBitmapData(r.width, r.height, true, 0x00ff0000);
            tmpBD.draw(originClip, m, null, null, null, true);
            //Color bounds - save memory, now disabled
            /* var rectColor:Rectangle = tmpBD.getColorBoundsRect(0xFF000000, 0x00000000, false);
             if (rectColor.width >0 && r.height >0) {
             var bmpData : VBitmapData = new VBitmapData(rectColor.width, rectColor.height, true, 0);
             bmpData.copyPixels(tmpBD, rectColor, tmpP);
             }
             rectPos = null;
             if (bmpData) {
             tmpBD = bmpData;
             rectPos = new Point(rectColor.x, rectColor.y);
             } */
            //Optimize 1: -- Check for duplicate, save above 50% of memory
            if (framesBD.length - 1 >= 0 && framesBD[framesBD.length - 1]) {
                if (framesBD[framesBD.length - 1].compare(tmpBD) === 0) {
                    //trace("the same bitmap data "+originClip);
                    tmpBD = framesBD[framesBD.length - 1];
                }
            }
            //Optimize 2: New version of 1, check with all previous frames, take longer time, save +30% of RAM then first version
            /* if (framesBD.length > 0) {
             for (var i:int = 0; i < framesBD.length; i++) 
             {
             if (framesBD[i].compare(tmpBD) === 0) {
             tmpBD = framesBD[i];
             break;
             }
             }
             }
             //Optimize 3: Remove full transparent zones with help of color bounds, NOT WORK
             var rectColor:Rectangle = tmpBD.getColorBoundsRect(0xFF000000, 0x00000000, false);
             if (rectColor.width >0 && (r.width > rectColor.width || r.height > rectColor.height)) {
             var bmpData : VBitmapData = new VBitmapData(rectColor.width, rectColor.height, true, 0);
             bmpData.copyPixels(tmpBD, rectColor, tmpP);
             }
             if (bmpData) tmpBD = bmpData;
             if (!forPhysic) {
             tmpBD.drawRect(new Rectangle(1,1, tmpBD.width-2, tmpBD.height-2), 0x33000000);
             } */
            //
            return tmpBD;
        } else {
            trace("Error: No good bitmap: " + originClip);
            return null;
        }
    }

}
}