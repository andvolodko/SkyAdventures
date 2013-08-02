/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 10.04.12
 * Time: 9:24
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.components {
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.VBitmapData;
import org.volodko.engine.VSprite;
import org.volodko.engine.cache.ChildData;
import org.volodko.engine.cache.ClipData;

public class Graphic extends Component {

    private var displayObject:DisplayObject;
    private var displayMC:MovieClip;
    private var cachedData:VSprite;
    private var _x:Number = 0;
    private var _y:Number = 0;
    private var _rotation:Number = 0;
    private var _visible:Boolean = true;
    private var _position:Point = new Point();
    private var _cachedPosition:Point;

    public function Graphic(entity:Entity, displayObject:DisplayObject = null) {
        this.displayObject = displayObject;
        super(entity);
    }

    override public function init():void {
        super.init();
        //
        if(displayObject is VSprite) {
            cachedData = VSprite(displayObject);
            _cachedPosition = new Point();
        } else if(displayObject is MovieClip){
            displayMC = MovieClip(displayObject);
        }
    }

    public function getClip():DisplayObject {
        return displayObject;
    }

    public function currLabel():String {
        return displayMC.currentLabel;
    }

    public function currFrame():int {
        return displayMC.currentFrame;
    }

    public function goAndStop(frame:String):void {
        displayMC.gotoAndStop(frame);
    }

    public function goAndPlay(frame:String):void {
        displayMC.gotoAndPlay(frame);
    }

    //-------------  -------------
    public function set x(value:Number):void {
        _x = value;
    }
    public function set y(value:Number):void {
        _y = value;
    }
    public function get x():Number {
        return _x;
    }
    public function get y():Number {
        return _y;
    }

    public function get visible():Boolean {
        return _visible;
    }

    public function set position(val:Point):void { _position = val; }
    public function get position():Point {
        _position.x = x; _position.y = y;
        return _position;
    }

    public function getBD():VBitmapData {
        return cachedData.getBD();
        //TODO for casual MC
    }

    public function getPoint():Point {
        return cachedData.getPoint();
        //TODO for casual MC
    }
    
    //Rotation
    public function set rotation(val:Number):void {
        _rotation = val;
    }
    public function get rotation():Number {
        return _rotation;
    }

    public function getRotationMargin():Point {
        //TODO rotate this point
        return cachedData.getPoint().clone();
    }

    public function get cachedPosition():Point {
        _cachedPosition.x = x + cachedData.getPoint().x;
        _cachedPosition.y = y + cachedData.getPoint().y;
        return _cachedPosition;
    }

    public function haveChild(childName:String):Boolean {
        if(cachedData && cachedData.haveChild(childName)) {
            return true;
        } else if(displayMC && displayMC[childName]) {
            return true;
        }
        return false;
    }

    public function getClipData():ClipData {
        return cachedData.getClipData();
    }

    public function getChildData(childName:String):ChildData {
        return cachedData.getChildData(childName);
    }
}
}
