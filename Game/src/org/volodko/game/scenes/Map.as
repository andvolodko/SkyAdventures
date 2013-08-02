/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 07.04.12
 * Time: 3:24
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.scenes {
import flash.events.Event;

import org.volodko.engine.GLB;
import org.volodko.engine.GroupsVO;

import org.volodko.engine.Languages;
import org.volodko.engine.MsgVO;

import org.volodko.engine.Scene;
import org.volodko.engine.ui.buttons.TextButton;
import org.volodko.game.helpers.GameFunctions;

public class Map extends Scene {
    public function Map() {
        trace("map Create");
        super(MapGr);
    }

    override protected function initialize(e:Event = null):void {
        super.initialize(e);
        //
        var lng:Languages =  Languages(GLB.engine.getModule(Languages));
        addEntity(new TextButton(graphicClip["menu"], menuClick, null, lng.get("menu")));
        //
        startAnim();
    }

    private function menuClick():void {
        //dispatch(MsgVO.STATE, Menu, GroupsVO.SYSTEM);
        dispatch(MsgVO.STATE, GameLevel, GroupsVO.SYSTEM);
    }

    //--------- Help animations ----------
    private function startAnim():void {
        /*
        var startPos:Vector.<Number> = new Vector.<Number>();
        startPos.push(graphicClip["moon"].y);
        startPos.push(graphicClip["gamename"].y);
        startPos.push(graphicClip["cloud1"].y);
        startPos.push(graphicClip["cloud2"].y);
        startPos.push(graphicClip["cloud3"].y);
        startPos.push(graphicClip["cloud4"].y);
        startPos.push(graphicClip["cloud5"].y);
        startPos.push(graphicClip["castle"].y);
        startPos.push(graphicClip["newGame"].y);
        startPos.push(graphicClip["toContinue"].y);
        startPos.push(graphicClip["island"].y);
        //Move up
        var subtractY:Number = 1000;
        graphicClip["moon"].y -= subtractY;
        graphicClip["gamename"].y -= subtractY;
        graphicClip["cloud1"].y -= subtractY;
        graphicClip["cloud2"].y -= subtractY;
        graphicClip["cloud3"].y -= subtractY;
        graphicClip["cloud4"].y -= subtractY;
        graphicClip["cloud5"].y -= subtractY;
        graphicClip["castle"].y -= subtractY;
        graphicClip["newGame"].y -= subtractY;
        graphicClip["toContinue"].y -= subtractY;
        graphicClip["island"].y -= subtractY;
        //Anim down
        var animTime:Number = 1.2;
        GameFunctions.addAnim(graphicClip["moon"], startPos[0], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["gamename"], startPos[1], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["cloud1"], startPos[2], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["cloud2"], startPos[3], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["cloud3"], startPos[4], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["cloud4"], startPos[5], animTime * 0.7);
        GameFunctions.addAnim(graphicClip["cloud5"], startPos[6], animTime * 0.8);
        GameFunctions.addAnim(graphicClip["castle"], startPos[7], animTime * 0.8);
        GameFunctions.addAnim(graphicClip["newGame"], startPos[8], animTime  * 0.9);
        GameFunctions.addAnim(graphicClip["toContinue"], startPos[9], animTime * 0.9);
        GameFunctions.addAnim(graphicClip["island"], startPos[10], animTime);
        */
    }

}
}
