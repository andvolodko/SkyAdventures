/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 09.04.12
 * Time: 3:20
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.helpers {
import caurina.transitions.Tweener;

import flash.display.DisplayObject;

public class GameFunctions {
    public function GameFunctions() {
    }
    static public function animateObject(cloudGr:DisplayObject, distanceX:Number, distanceY:Number, time:Number):void{
        var orPosY:Number = cloudGr.y;
        var orPosX:Number = cloudGr.x;
        Tweener.addTween(cloudGr, {time:time, y:orPosY + distanceY, x:orPosX + distanceX, transition:"easeInOutSine", onComplete:function():void{
            Tweener.addTween(cloudGr, {time:time, y:orPosY, x:orPosX, transition:"easeOutSine", onComplete:function():void{
                animateObject(cloudGr, distanceX, distanceY, time);
            }})
        }});
    }
    static public function addAnim(animGr:DisplayObject, posY:Number, time:Number, atEnd:Function = null):void {
        Tweener.addTween(animGr, {time:time, y:posY, transition:"easeInOutSine", onComplete:atEnd});
    }
}
}
