package org.volodko.engine {
import caurina.transitions.Tweener;

import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import org.volodko.engine.utils.LoDMath;

public class PixelDisplay extends Module {
    
    private var displayBD:VBitmapData;
    private var displayBitmap:Bitmap;
    private var displaySprite:Sprite;
    //
    private var matrix:Matrix;
    //
    private var smoothing:Boolean = true;
    //
    public function PixelDisplay(smoothing:Boolean = true) {
        this.smoothing = smoothing;
        super();
        init();
    }

    public function init():void {
        //
        //trace(GLB.width, GLB.height);
        displayBD = new VBitmapData(GLB.width, GLB.height, true);
        displayBitmap = new Bitmap(displayBD);
        displayBitmap.smoothing = smoothing;
        displaySprite = new Sprite();
        displaySprite.addChild(displayBitmap);
        GLB.stage.addChild(displaySprite);
        GLB.stage.setChildIndex(displaySprite, 0);
        //
        matrix = new Matrix();
        //
        addListeners();
    }

    public function getSmoothing():Boolean {
        return smoothing;
    }

    override public function update():void {
        super.update();
        //
        //Debug
        //debugDraw();
        //postUpdate();
    }



    //---------------- render interface -------------
    public function drawNow(bdToCopy:VBitmapData, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null):void {
        displayBD.lock();
        //matrix.identity();
        //matrix.scale(0.7,0.7);
        //matrix.translate(20,20);
        displayBD.draw(bdToCopy, matrix, colorTransform, blendMode, clipRect, smoothing);
        displayBD.unlock();
    }
    public function renderNow(bdToCopy:VBitmapData, pos:Point, rotation:Number = 0, rotMargin:Point = null):void {
        //
        displayBD.lock();
        if (rotation != 0) {
            //Draw
            matrix.identity();
            if (rotMargin) matrix.translate(rotMargin.x, rotMargin.y);
            matrix.rotate(LoDMath.degreesToRadians(rotation));
            if (rotMargin) matrix.translate(-rotMargin.x, -rotMargin.y);
            matrix.translate(pos.x, pos.y);
            displayBD.draw(bdToCopy, matrix, null, null, null, true);
        } else {
            //Copy pixels
            displayBD.copyPixels(bdToCopy, bdToCopy.rect, pos, null, null, true);
        }
        displayBD.unlock();
    }
    public function clearBD():void {
        displayBD.fillRect(displayBD.rect, 0);
    }
    public function getDisplayBD():VBitmapData { return displayBD;}
    public function getDisplayBitmap():Bitmap { return displayBitmap; }
    public function getDisplaySprite():Sprite { return displaySprite; }
    //Listeners
    private function mu(e:MouseEvent):void {
        dispatch(MsgVO.PIX_DISPLAY_UP, {x:e.stageX, y:e.stageY});
    }

    private function md(e:MouseEvent):void {
        dispatch(MsgVO.PIX_DISPLAY_DOWN, {x:e.stageX, y:e.stageY});
    }

    private function mout(e:MouseEvent):void {
        dispatch(MsgVO.PIX_DISPLAY_OUT);
    }

    private function mover(e:MouseEvent):void {
        dispatch(MsgVO.PIX_DISPLAY_OVER);
    }

    private function addListeners():void {
        displaySprite.addEventListener(MouseEvent.MOUSE_DOWN, md);
        displaySprite.addEventListener(MouseEvent.MOUSE_UP, mu);
        displaySprite.addEventListener(MouseEvent.MOUSE_OVER, mover);
        displaySprite.addEventListener(MouseEvent.MOUSE_OUT, mout);
    }

    private function removeListeners():void {
        displaySprite.removeEventListener(MouseEvent.MOUSE_DOWN, md);
        displaySprite.removeEventListener(MouseEvent.MOUSE_UP, mu);
        displaySprite.removeEventListener(MouseEvent.MOUSE_OVER, mover);
        displaySprite.removeEventListener(MouseEvent.MOUSE_OUT, mout);
    }

}

}
