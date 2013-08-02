package org.volodko.engine
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.text.TextField;
import flash.utils.getDefinitionByName;

/**
 * ...
 * @author Andrey.Volodko.org
 */
public class Preloader extends MovieClip
{
    private var startClass:String;
    private var preloaderGraphic:DisplayObjectContainer;
    //
    private var playBtns:Vector.<String> = new Vector.<String>();
    private var loadLbls:Vector.<String> = new Vector.<String>();
    //
    private var logoString:String;
    //
    private var noSoundName:String;
    private var noSoundFunc:Function;
    

    public function Preloader(startClass:String)
    {
        this.startClass = startClass;
        if (stage) {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.BEST;
        }
        addEventListener(Event.ENTER_FRAME, checkFrame);
        loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
        loaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);

        // TODO show loader
        trace("Preloader start");
    }

    private function loadComplete(event:Event):void {
        for (var i:int = 0; i < playBtns.length; i++) {
            preloaderGraphic[playBtns[i]].visible = true;
        }
        //
        if(noSoundName != null) preloaderGraphic[noSoundName].visible = true;
    }

    protected function initialize():void {
        for (var i:int = 0; i < playBtns.length; i++) {
            preloaderGraphic[playBtns[i]].visible = false;
        }
        //
        if(noSoundName != null) preloaderGraphic[noSoundName].visible = false;
    }

    private function ioError(e:IOErrorEvent):void
    {
        trace(e.text);
    }

    private function progress(e:ProgressEvent):void
    {
        // TODO update loader
        var percent:int = (Number(e.bytesLoaded/e.bytesTotal)*100);
        trace("Loaded: "+percent+" %");
        //
        for (var i:int = 0; i < loadLbls.length; i++) {
            var loadTF:TextField = preloaderGraphic[loadLbls[i]];
            loadTF.text = percent+"%";
        }
    }

    private function checkFrame(e:Event):void
    {
        if (currentFrame == totalFrames)
        {
            //stop();
            //loadingFinished();
        }
    }

    private function loadingFinished():void
    {

    }

    public function startup():void
    {
        //Clean previous
        removeEventListener(Event.ENTER_FRAME, checkFrame);
        loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
        removeChild(preloaderGraphic);
        for (var i:int = 0; i < playBtns.length; i++) {
            preloaderGraphic[playBtns[i]].removeEventListener(MouseEvent.CLICK, playClick);
        }
        if(logoString) preloaderGraphic[logoString].removeEventListener(MouseEvent.CLICK, logoClick);
        if(noSoundName) preloaderGraphic[noSoundName].removeEventListener(MouseEvent.CLICK, noSndClick);
        //
        var mainClass:Class = getDefinitionByName(startClass) as Class;
        addChild(new mainClass() as DisplayObject);
    }


    //Special features
    public function getGraphic():DisplayObjectContainer {
        return preloaderGraphic;
    }
    protected function addGraphic(clipClass:Class):void {
        preloaderGraphic = (new clipClass()) as DisplayObjectContainer;
        addChild(preloaderGraphic);
    }
    protected function addLogo(logoString:String):void {
        this.logoString = logoString;
        preloaderGraphic[logoString].addEventListener(MouseEvent.CLICK, logoClick);
    }
    protected function addPlayButton(playString:String):void {
        playBtns.push(playString);
        preloaderGraphic[playString].addEventListener(MouseEvent.CLICK, playClick);
    }

    protected function addLoadingLabel(loadLbl:String):void {
        loadLbls.push(loadLbl);
    }

    protected function addNoSoundButton(mcName:String, noSoundsFunc:Function):void {
        noSoundName = mcName;
        this.noSoundFunc = noSoundsFunc;
        preloaderGraphic[noSoundName].buttonMode = true;
        preloaderGraphic[noSoundName].addEventListener(MouseEvent.CLICK, noSndClick);
        preloaderGraphic[noSoundName].gotoAndStop(1);
    }
    
    public function playClick(e:Event):void {
        startup();
    }

    private function logoClick(e:Event):void {
        trace("logo click");
    }

    private function noSndClick(event:MouseEvent):void {
        if(noSoundFunc != null) noSoundFunc();
        if(MovieClip(preloaderGraphic[noSoundName]).currentFrame == 2) preloaderGraphic[noSoundName].gotoAndStop(1);
        else preloaderGraphic[noSoundName].gotoAndStop(2);
    }
}

}