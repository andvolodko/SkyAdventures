package org.volodko.engine.ui.buttons {

import flash.display.MovieClip;

import org.volodko.engine.Entity;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.MouseInteract;
import org.volodko.engine.components.States;

public class BaseButton extends Entity {
    protected var clip:MovieClip;
    protected var callback:Function;
    protected var checkFunc:Function;

    public function BaseButton(clip:MovieClip, callback:Function, checkFunc:Function = null) {
        this.clip = clip;
        this.callback = callback;
        this.checkFunc = checkFunc;
        super();

    }

    override public function init():void {
        super.init();
        //
        addComponent(new Graphic(this, clip));
        addComponent(new States(this));
        addComponent(new MouseInteract(this));
        addComponent(new BaseButtonBehaviour(this, callback, checkFunc));
        //
        initComponents();
    }

}

}