package org.volodko.engine.ui.buttons {


import flash.display.MovieClip;

import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.MouseInteract;
import org.volodko.engine.components.States;

public class TextButton extends BaseButton {
    protected var name:String;

    public function TextButton(clip:MovieClip, callback:Function, checkFunc:Function, name:String) {
        this.name = name;
        super(clip, callback, checkFunc);

    }

    override public function init():void {
        preInit();
        //
        addComponent(new Graphic(this, clip));
        addComponent(new States(this));
        addComponent(new MouseInteract(this));
        addComponent(new TextButtonBehaviour(this, callback, checkFunc, name));
        //
        initComponents();
    }
}

}