/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 23.04.12
 * Time: 1:34
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities {
import caurina.transitions.Tweener;
import caurina.transitions.properties.ColorShortcuts;
import caurina.transitions.properties.CurveModifiers;
import caurina.transitions.properties.FilterShortcuts;

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.geom.ColorTransform;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.getTimer;

import org.volodko.engine.Entity;
import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.MsgVO;
import org.volodko.engine.PixelDisplay;
import org.volodko.engine.TileMap;
import org.volodko.engine.VBitmapData;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.physic.Physic;
import org.volodko.engine.utils.TransitionsVO;

public class PixelCamera extends Entity {

    private var pixelDisplay:PixelDisplay;
    private var tileMap:TileMap;
    private var mapBD:VBitmapData;
    private var displayBD:VBitmapData;
    private var displayBitmap:Bitmap;
    private var matrix:Matrix = new Matrix();
    private var mapMargin:int;
    private var aspectRatio:Number;
    private var displayWidth2:int;
    private var displayHeight2:int;
    private var mapWidth2:int;
    private var mapHeight2:int;
    //
    private var followSpeed:Number = 5;
    private var graphicFollow:Graphic;
    private var dx:Number = 0;
    private var dy:Number = 0;
    private var minScaleX:Number = 1;
    private var minScaleY:Number = 1;
    //For shake
    private var shakeTimes:int = 20;
    private var shakeDist:Number = 0;
    //For color effects
    private var colorTransform:ColorTransform = new ColorTransform(1,1,1,0,0,0,0,1);
    private var colorTransformTemp:ColorTransform = null;


    public function PixelCamera() {
        super();
    }

    override public function init():void {
        super.init();
        //
        //
        initComponents();
        //
        pixelDisplay = PixelDisplay(GLB.engine.getModule(PixelDisplay));
        tileMap = TileMap(GLB.engine.getModule(TileMap));
        //
        displayWidth2 = GLB.engine.width/2; 
        displayHeight2 = GLB.engine.height/2;
        mapWidth2 = tileMap.getMapBD().width/2;
        mapHeight2 = tileMap.getMapBD().height/2;
        //
        mapBD = tileMap.getMapBD();
        displayBD = pixelDisplay.getDisplayBD();
        displayBitmap = pixelDisplay.getDisplayBitmap();
        mapMargin = tileMap.getMargin();
        aspectRatio = tileMap.getAspectRation();
        //
        minScaleX = displayBD.width/mapBD.width;
        minScaleY = displayBD.height/mapBD.height;
        minScaleX = Number(minScaleX.toFixed(4));
        minScaleY = Number(minScaleY.toFixed(4));
        //
        CurveModifiers.init();
        FilterShortcuts.init();
        ColorShortcuts.init();
        //
        //For physic debug
        CONFIG::debug {
            var physic:Physic = Physic(GLB.engine.getModule(Physic));
            physic.setMatrix(matrix);
        }
    }

    override public function update():void {
        super.update();
        //
    }

    override public function postUpdate():void {
        super.postUpdate();
        //
        CONFIG::debug {
            var st:Number = getTimer();
        }
        //Graphic follow update
        if(graphicFollow) {
            dx = tileMap.offsetXSetter - graphicFollow.x + mapWidth2;
            dy = tileMap.offsetYSetter - graphicFollow.y + mapHeight2;
            tileMap.offsetXSetter -= dx / followSpeed;
            tileMap.offsetYSetter -= dy / followSpeed;
        }
        //
        pixelDisplay.clearBD();
        //
        //With out consider zoom margin
        matrix.tx = int(-(mapBD.width*matrix.a)/2 + displayWidth2);
        matrix.ty = int(-(mapBD.height*matrix.d)/2 + displayHeight2);
        //TODO: maybe add consider zoom margin
        //if(tileMap.offsetXSetter <= 0) matrix.tx = -mapBD.width*matrix.a/2 + displayWidth2;
        //if(tileMap.offsetYSetter <= 0)matrix.ty = -mapBD.height*matrix.d/2 + displayHeight2;
        
        pixelDisplay.drawNow(mapBD, matrix, colorTransformTemp);
        //
        CONFIG::debug {
            var et:Number = getTimer();
            dispatch(MsgVO.LOG_TEMP, "Camera time: <b>" + ((et - st) / 1000) + "</b>", GroupsVO.DEBUG);
        }
    }
    
    public function setScale(sx:Number, sy:Number):void {
        scaleX = sx;
        scaleY = sy;
    }
    public function get scaleX():Number { return matrix.a; }
    public function get scaleY():Number { return matrix.d; }
    public function set scaleX(val:Number):void {
        if(val < minScaleX) val = minScaleX;
        matrix.a = val;
    }
    public function set scaleY(val:Number):void {
        if(val < minScaleY) val = minScaleY;
        matrix.d = val;
    }

    //Camera effects
    /*
    @coef - 0-2 value
     */
    public function zoom(coef:Number, time:Number = 0, delay:Number = 0, onFinish:Function = null, transition:String = TransitionsVO.EASE_NONE):void {
        Tweener.addTween(this, {time:time, scaleX:coef, scaleY:coef, delay:delay,
            transition:transition, onComplete:onFinish});
    }
    public function fade(time:Number = 0, onFinish:Function = null, transition:String = TransitionsVO.EASE_NONE, delay:Number = 0):void {
        Tweener.addTween(displayBitmap, {time:time, _brightness:-3, delay:delay,
            transition:transition, onComplete:onFinish});
    }

    public function fadeEnd(time:Number = 0, delay:Number = 0, onFinish:Function = null, transition:String = TransitionsVO.EASE_NONE):void {
        Tweener.addTween(displayBitmap, {time:time, _brightness:0, delay:delay,
            transition:transition, onComplete:onFinish});
    }

    public function setGraphicFocus(graphic:Graphic, time:Number = 0, onFinish:Function = null, transition:String = TransitionsVO.EASE_NONE, delay:Number = 0):void {
        //trace(graphic.x, graphic.y);
        //tileMap.setOffset(graphic.x-displayWidth2, graphic.y-displayHeight2);
        Tweener.addTween(tileMap, {time:time, offsetXSetter:graphic.x-mapWidth2, offsetYSetter:graphic.y-mapHeight2,
            delay:delay, transition:transition, onComplete:onFinish});
    }

    public function setGraphicFollow(graphic:Graphic, speed:Number = NaN):void {
        if(speed) followSpeed = speed;
        graphicFollow = graphic;
    }

    public function shake(shakeDist:Number, shakeTimes:int = 10, time:Number = 1, delay:Number = 0, onFinish:Function = null, transition:String = TransitionsVO.EASE_NONE ):void {
        this.shakeDist = shakeDist;
        this.shakeTimes = shakeTimes;
        Tweener.addCaller(this, {
            onUpdate:shakeOnce,
            count:shakeTimes,
            time:time,
            delay:delay,
            transition:transition,
            onComplete:onFinish, waitFrames:true});
    }
    private function shakeOnce():void {
        tileMap.offsetXSetter += shakeDist/2 + +Math.random()*shakeDist-shakeDist;
        tileMap.offsetYSetter += shakeDist/2 + +Math.random()*shakeDist-shakeDist;
    }
}
}
