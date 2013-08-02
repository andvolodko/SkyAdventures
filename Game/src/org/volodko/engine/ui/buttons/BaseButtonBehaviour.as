package org.volodko.engine.ui.buttons {
import flash.display.DisplayObjectContainer;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.MsgVO;
import org.volodko.engine.components.Graphic;
import org.volodko.engine.components.MouseInteract;
import org.volodko.engine.components.States;

public class BaseButtonBehaviour extends Component {
    //
    static protected const STATE_OUT:int = 1;
    static protected const STATE_OVER:int = 2;
    static protected const STATE_DOWN:int = 3;
    static protected const STATE_OFF:int = 4;
    static protected const STATE_UP:int = 5;
    //
    static protected const ANIM_OUT:String = "out";
    static protected const ANIM_OVER:String = "over";
    static protected const ANIM_DOWN:String = "down";
    static protected const ANIM_DISABLED:String = "disabled";
    //
    protected var graphic:Graphic;
    protected var states:States;
    protected var clip:DisplayObjectContainer;
    protected var mouse:MouseInteract;
    //
    protected var callback:Function;
    protected var checkFunc:Function;
    //
    protected var clicked:Boolean = false;
    //
    public function BaseButtonBehaviour(entityLoc:Entity, callback:Function, checkFunc:Function = null) {
        this.callback = callback;
        this.checkFunc = checkFunc;
        super(entityLoc);

    }

    override public function init():void {
        super.init();
        //
        graphic = Graphic(getComponent(Graphic));
        clip = DisplayObjectContainer(graphic.getClip());
        states = States(getComponent(States));
        mouse = MouseInteract(getComponent(MouseInteract));
        //
        clip.mouseChildren = false;
        //
        entity.registerLocal(receive, GroupsVO.MOUSE);
        setState(STATE_OUT);
    }

    override public function update():void {
        super.update();
        //
        checkEnabled();
    }

    protected function checkEnabled():void {
        if (checkFunc != null) {
            var res:Boolean = checkFunc();
            if (!res && states.getState() != STATE_OFF) setState(STATE_OFF);
            if (res && states.getState() == STATE_OFF) setState(STATE_OUT);
        }
    }

    protected function setState(stateLoc:int):void {
        states.setState(stateLoc);
        //
        switch (states.getState()) {
            case STATE_OUT:
                states.setAnim(ANIM_OUT);
                if (!mouse.isEnabled()) mouse.enable();
                break;
            case STATE_OVER:
                states.setAnim(ANIM_OVER);
                break;
            case STATE_DOWN:
                states.setAnim(ANIM_DOWN);
                dispatch(MsgVO.BUTTON_CLICK, null, GroupsVO.UI);
                break;
            case STATE_UP:
                if (callback != null) {
                    callback();
                    //trace("TextBut callback");
                }
                states.setAnim(ANIM_OVER);
                clicked = true;
                break;
            case STATE_OFF:
                states.setAnim(ANIM_DISABLED);
                mouse.onMouseOut(null);
                mouse.disable();
                break;
        }
    }

    /* --------------------------------- Receive local messages -------------------------------- */
    public function receive(msg:String, data:Object):void {
        //
        if (states.getState() == STATE_OFF) return;
        //
        switch (msg) {
            case MsgVO.BUTTON_UP:
                setState(STATE_UP);
                break;
            case MsgVO.BUTTON_OVER:
                setState(STATE_OVER);
                break;
            case MsgVO.BUTTON_DOWN:
                setState(STATE_DOWN);
                break;
            case MsgVO.BUTTON_OUT:
                setState(STATE_OUT);
                break;
        }
    }
}

}