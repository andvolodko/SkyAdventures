package org.volodko.engine.components {

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import org.volodko.engine.Component;
import org.volodko.engine.Entity;
import org.volodko.engine.GroupsVO;
import org.volodko.engine.MsgVO;
import org.volodko.engine.components.Graphic;

public class MouseInteract extends Component {
    private var graphic:Graphic;
    private var clip:DisplayObject;

    public function MouseInteract(entityLoc:Entity) {
        super(entityLoc);

    }

    override public function init():void {
        super.init();
        //
        graphic = Graphic(getComponent(Graphic));
        clip = graphic.getClip();
        addListeners();
    }

    public function onMouseOut(e:MouseEvent):void {
        if (!enabled) return;
        dispatch(MsgVO.BUTTON_OUT, null, GroupsVO.MOUSE);
        send(MsgVO.BUTTON_OUT, null, GroupsVO.MOUSE);
    }

    public function onMouseOver(e:MouseEvent):void {
        if (!enabled) return;
        dispatch(MsgVO.BUTTON_OVER, null, GroupsVO.MOUSE);
        send(MsgVO.BUTTON_OVER, null, GroupsVO.MOUSE);
    }

    public function onMouseDown(e:MouseEvent):void {
        if (!enabled) return;
        dispatch(MsgVO.BUTTON_DOWN, null, GroupsVO.MOUSE);
        send(MsgVO.BUTTON_DOWN, null, GroupsVO.MOUSE);
    }

    public function onMouseUp(e:MouseEvent):void {
        if (!enabled) return;
        dispatch(MsgVO.BUTTON_UP, null, GroupsVO.MOUSE);
        send(MsgVO.BUTTON_UP, null, GroupsVO.MOUSE);
    }

    private function onMouseMove(e:MouseEvent):void {
        if (!enabled) return;
        dispatch(MsgVO.BUTTON_OVER, null, GroupsVO.MOUSE);
        send(MsgVO.BUTTON_OVER, null, GroupsVO.MOUSE);
    }

    public function addListeners():void {
        clip.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        clip.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        clip.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        clip.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        clip.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    public function removeListeners():void {
        clip.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        clip.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        clip.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        clip.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        clip.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    override public function remove():void {
        super.remove();
        removeListeners();
    }

}

}