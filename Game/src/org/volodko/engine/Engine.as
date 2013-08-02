/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 23.03.12
 * Time: 23:48
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import org.volodko.engine.interfaces.IUpdatable;

public class Engine extends Sprite implements IUpdatable {


    private var startSceneClass:Class;
    //
    private var prevFrameTime:Number = 0;
    private var frameTime:Number;
    private var currentScene:Scene;
    private var modules:Vector.<Module> = new Vector.<Module>();
    private var components:Vector.<Component> = new Vector.<Component>(); //All current components
    private var entities:Vector.<Entity> = new Vector.<Entity>(); //All current entities
    private var isFocus:Boolean = true;
    //
    public function Engine(startSceneClass:Class) {
        super();
        trace("Engine start");
        this.startSceneClass = startSceneClass;
        if(stage) initialize(); else addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function initialize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initialize);
        //Entry point
        stage.addEventListener(Event.ENTER_FRAME, enterFrame);
        stage.addEventListener(Event.ACTIVATE, onActivate);
        stage.addEventListener(Event.DEACTIVATE, onDeactivate);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        //
        GLB.width = stage.stageWidth; GLB.height = stage.stageHeight;
        GLB.mx = GLB.width/2; GLB.my = GLB.height/2;
        GLB.stage = stage;
        GLB.engine = this;
        //Remove yellow border from focus
        stage.stageFocusRect = false;
        //
        addModule(GLB.signals = new Signals()); //First
        GLB.signals.register(signalListener, GroupsVO.SYSTEM);
        addMask();
        //
        CONFIG::debug {
            GLB.signals.register(debugListener, GroupsVO.DEBUG);
        }
    }
    public function launchStartState():void {
        //Launch state
        currentScene = new startSceneClass() as Scene;
        if(currentScene) addChild(currentScene);
        stage.focus = this;
    }
    //----------------- Every frame update -------------
    private function enterFrame(e:Event):void
    {
        update();
    }

    public function update():void {
        CONFIG::debug {
            updateJob();
        }
        CONFIG::release {
            try {
                updateJob();
            } catch (err:Error) {
                //trace(err);
                //Global error handling
                //NNLG.signals.dispatch("log_trace", err.getStackTrace());
            }
        }
    }
    public function postUpdate():void {
    }
    private function updateJob():void
    {
        // Elapsed time
        frameTime = getTimer();
        prevFrameTime = frameTime - prevFrameTime;
        GLB.elapsed = prevFrameTime / 1000;
        prevFrameTime = frameTime;
        GLB.frames++;
        GLB.totalElapsed += GLB.elapsed;
        //
        CONFIG::debug {
            var st:Number = getTimer();
        }
        //
        for (var i:int = 0; i < modules.length; ++i)
        {
            modules[i].update();
        }
        //-----------------------------------------
        if(currentScene) currentScene.update();
        //
        for (i = 0; i < modules.length; ++i)
        {
            modules[i].postUpdate();
        }
        //
        CONFIG::debug {
            var et:Number = getTimer();
            GLB.signals.dispatchSignal(MsgVO.LOG_TEMP, "Logic time: <b>"+((et-st)/1000)+"</b>", GroupsVO.DEBUG);
        }
    }
    //---------------- Events handlers -------------
    private function onMouseMove(evt:MouseEvent):void {
        GLB.oldmx = GLB.mx;
        GLB.oldmy = GLB.my;
        GLB.mx =  evt.stageX;
        GLB.my = evt.stageY;
    }
    private function onDeactivate(e:Event):void
    {
        //trace("Focus lost");
        isFocus = false;
    }
    private function onActivate(e:Event):void
    {
        //trace("Focus yes");
        isFocus = true;
    }

    public function addModule(module:Module):void {
        modules.push(module);
    }
    public function getModule(moduleClass:Class):Module {
        for each (var module:Module in modules) {
            if(module is moduleClass) return module;
        }
        return null; //Exception
    }
    /* ------------------------------------- Components functions ------------------------------------- */
    public function addComponent(comp:Component):void {
        for (var i:int = 0; i < components.length; ++i)
        {
            if (components[i] == comp) {
                trace("Add component error: already have");
                return;
            }
        }
        components.push(comp);
    }
    public function removeComponent(comp:Component):void {
        for (var i:int = 0; i < components.length; ++i)
        {
            if (components[i] == comp) {
                components.splice(i, 1);
            }
        }
    }
    public function getComponents(compClass:Class):Array {
        var retArr:Array = [];
        for (var i:int = 0; i < components.length; ++i)
        {
            if (components[i] is compClass) retArr.push(components[i]);
        }
        return retArr;
    }
    public function getComponent(compClass:Class):Component {
        for (var i:int = 0; i < components.length; ++i)
        {
            if (components[i] is compClass) return components[i];
        }
        return null; // No this component
    }
    //------ For entities
    public function addEntity(ent:Entity):void {
        for (var i:int = 0; i < entities.length; ++i)
        {
            if (entities[i] == ent) {
                trace("Add entity error: already have");
                return;
            }
        }
        entities.push(ent);
    }
    public function removeEntity(ent:Entity):void {
        for (var i:int = 0; i < entities.length; ++i)
        {
            if (entities[i] == ent) {
                entities.splice(i, 1);
            }
        }
    }
    public function getEntities(entClass:Class):Array {
        var retArr:Array = [];
        for (var i:int = 0; i < entities.length; ++i)
        {
            if (entities[i] is entClass) retArr.push(entities[i]);
        }
        return retArr;
    }
    public function getEntity(entClass:Class):Entity {
        for (var i:int = 0; i < entities.length; ++i)
        {
            if (entities[i] is entClass) return entities[i];
        }
        return null; // No entity
    }
    public function getComponentInEntity(entClass:Class, compClass:Class):Component {
        var ent:Entity = getEntity(entClass);
        if (ent) var comp:Component = ent.getComponent(compClass);
        if (comp) return comp;
        else return null; // No this component
    }
    //------- Some help for entites and coms
    /*
     * Disable or enable components of entity
     */
    public function switchEntComponents(entClass:Class, entComs:Array, on:Boolean = false):void {
        var entArr:Array = getEntities(entClass);
        for (var i:int = 0; i < entArr.length; ++i)
        {
            for (var j:int = 0; j < entComs.length; ++j)
            {
                var comsArr:Array = Entity(entArr[i]).getComponents(entComs[j]);
                for (var k:int = 0; k < comsArr.length; k++)
                {
                    if (on) Component(comsArr[k]).enable();
                    else Component(comsArr[k]).disable();
                }
            }
        }
    }
    /*
     Set state func
     */
    private function setState(newClass:Class):void {
        if(contains(currentScene)) removeChild(currentScene);
        currentScene.remove();
        currentScene = new newClass() as Scene;
        if(currentScene) addChild(currentScene);
        stage.focus = this;
    }
    /*
    Signal listener
     */
    /* ------------------------------------- Signals listener --------------------------------------- */
    private function signalListener(msg:String, data:Object):void
    {
        switch(msg) {
            case MsgVO.STATE:
                setState(Class(data));
            break;
        }
    }
    /* ------------------------------------- Signals listener --------------------------------------- */
    private function debugListener(msg:String, data:Object):void
    {
        switch(msg) {
            //Commands
            case MsgVO.CONSOLE_COMMAND:
                switch(ConsoleCmd(data).commandName) {
                    case CmdVO.RESET:
                        setState(Class(getDefinitionByName(getQualifiedClassName(currentScene))));
                        break;
                }
                break;
        }
    }
    /*
     * Some help functions
     */
    private function addMask():void
    {
        var maskSprite:Sprite = new Sprite();
        maskSprite.graphics.beginFill(0x000000);
        maskSprite.graphics.drawRect(0, 0, GLB.width, GLB.height);
        maskSprite.graphics.endFill();
        mask = maskSprite;
        addChild(mask);
        setChildIndex(mask, 0);
    }

}
}
