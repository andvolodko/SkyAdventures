package org.volodko.game
{

import caurina.transitions.Tweener;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.StageScaleMode;
import flash.events.Event;

import org.volodko.engine.Preloader;
import org.volodko.game.helpers.GameFunctions;
import org.volodko.game.helpers.GameGLB;

/**
 * ...
 * @author Andrey.Volodko.org
 */
public class Preloader extends org.volodko.engine.Preloader {

    private var startClass:String = "org.volodko.game.Game";
    private var clicked:Boolean = false;

    public function Preloader()
    {
        super(startClass);
        //Initialize
        addGraphic(PreloaderGr);
        addLogo("logo");
        addPlayButton("playButton");
        addLoadingLabel("loading");
        addNoSoundButton("noSound", GameGLB.noSoundFunc);
        initialize();
        if (stage) stage.scaleMode = StageScaleMode.SHOW_ALL;
        //Animate
        var graphic:DisplayObjectContainer = getGraphic();
        //Clouds
        GameFunctions.animateObject(graphic["anim2"], 2, -3, 4);
        GameFunctions.animateObject(graphic["anim3"], 2, 3, 4);
        GameFunctions.animateObject(graphic["anim5"], 2, 2, 4);
        //Islands
        GameFunctions.animateObject(graphic["anim4"], 0, 5, 3);
        GameFunctions.animateObject(graphic["anim1"], 0, 5, 3);
        GameFunctions.animateObject(graphic["anim6"], 0, 5, 3);
        GameFunctions.animateObject(graphic["anim7"], 0, 3.5, 4);

    }

    //Preloader specific animation

    private function endAnimation(onEnd:Function):void {
        Tweener.removeAllTweens();
        var graphic:DisplayObjectContainer = getGraphic();
        var dist:Number = 1000; var time:Number = 1.5;
        GameFunctions.addAnim(graphic["moon"], graphic["moon"].y - dist, time);
        GameFunctions.addAnim(graphic["logo"], graphic["logo"].y - dist, time * 0.4);
        GameFunctions.addAnim(graphic["playButton"], graphic["playButton"].y - dist, time * 0.4);
        GameFunctions.addAnim(graphic["noSound"], graphic["noSound"].y - dist, time * 0.4);
        GameFunctions.addAnim(graphic["loadLbl"], graphic["loadLbl"].y - dist, time * 0.4);
        GameFunctions.addAnim(graphic["loading"], graphic["loading"].y - dist, time * 0.4);
        GameFunctions.addAnim(graphic["anim1"], graphic["anim1"].y - dist, time);
        GameFunctions.addAnim(graphic["anim2"], graphic["anim2"].y - dist, time);
        GameFunctions.addAnim(graphic["anim3"], graphic["anim3"].y - dist, time * 0.9);
        GameFunctions.addAnim(graphic["anim4"], graphic["anim4"].y - dist, time * 0.9);
        GameFunctions.addAnim(graphic["anim5"], graphic["anim5"].y - dist, time * 0.7);
        GameFunctions.addAnim(graphic["anim6"], graphic["anim6"].y - dist, time * 0.7);
        GameFunctions.addAnim(graphic["anim7"], graphic["anim7"].y - dist, time * 0.45, function():void{
            Tweener.removeAllTweens();
            onEnd();
        });
    }
    private function addAnim(animGr:DisplayObject, posY:Number, time:Number, atEnd:Function = null):void {
        Tweener.addTween(animGr, {time:time, y:posY, transition:"easeInSine", onComplete:atEnd});
    }
    override public function playClick(e:Event):void {
        if(clicked) return;
        clicked = true;
        endAnimation(startup);
    }
}

}