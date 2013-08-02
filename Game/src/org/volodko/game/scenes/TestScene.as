/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 27.04.12
 * Time: 3:16
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.scenes {
import flash.events.Event;

import org.volodko.engine.Scene;

public class TestScene extends Scene {
    public function TestScene(graphicClipClass:Class) {
        super(graphicClipClass);
    }

    override protected function initialize(e:Event = null):void {
        super.initialize(e);
        //
        /* for(var i:int=0;i<bezierPoints.length;++i){
            bezierPoints[i].offsetXSetter = tileMap.offsetXSetter + shakeDist/2 + +Math.random()*shakeDist-shakeDist;
            bezierPoints[i].offsetYSetter = tileMap.offsetYSetter + shakeDist/2 + +Math.random()*shakeDist-shakeDist;
        }
        Tweener.addTween(tileMap,{time:1,
            _bezier:bezierPoints,
            offsetXSetter:tileMap.offsetXSetter,
            offsetYSetter:tileMap.offsetYSetter,
            transition:TransitionsVO.EASE_IN_OUT_QUAD
        }); */
    }
}
}
