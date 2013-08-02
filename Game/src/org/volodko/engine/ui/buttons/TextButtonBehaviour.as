package org.volodko.engine.ui.buttons {
import flash.text.TextField;
import flash.text.TextFormat;

import org.volodko.engine.Entity;

public class TextButtonBehaviour extends BaseButtonBehaviour {
    protected var name:String;
    private var textFormat:TextFormat;

    public function TextButtonBehaviour(entityLoc:Entity, callback:Function, checkFunc:Function, name:String) {
        this.name = name;
        this.checkFunc = checkFunc;
        super(entityLoc, callback, checkFunc);

    }

    override public function init():void {
        super.init();
        //
        setName(name);
    }

    override public function update():void {
        super.update();
        //
        updateCaption();
    }

    override protected function setState(stateLoc:int):void {
        super.setState(stateLoc);
        updateCaption();
    }

    private function updateCaption():void {
        var caption:TextField = TextField(clip["text"]);
        if (caption) {
            textFormat = caption.getTextFormat();
            caption.text = name;
            if (textFormat.bold) caption.setTextFormat(textFormat);
            //if (textFormat.bold) clip.caption.htmlText = "<b>" + name + "</b>";
        }
    }

    // Interface
    public function setName(name:String):void {
        this.name = name;
        setState(states.getState());
    }

    public function setActive():void {
        setState(STATE_OUT);
    }

    public function setDisabled():void {
        setState(STATE_OFF);
    }

}

}