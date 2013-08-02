/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 09.04.12
 * Time: 1:45
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import org.volodko.engine.GameObject;
import org.volodko.engine.interfaces.IEnableDisable;
import org.volodko.engine.interfaces.IUpdatable;

public class Entity extends GameObject implements IUpdatable, IEnableDisable {
    protected var enabled:Boolean = true;
    //
    private var components:Vector.<OneComponent>;
    private var signals:Signals;
    //
    private var postUpdateVec:Vector.<PostUpdateFunc>;
    private var initEnd:Vector.<Function>;
    //Child entities
    private var entities:Vector.<Entity>;
    //
    public function Entity() {
        GLB.engine.addEntity(this);
        init();
    }

    public function init():void
    {
        preInit();
        //initComponents();
    }
    public function preInit():void {
        components = new Vector.<OneComponent>();
        entities = new Vector.<Entity>();
        signals = new Signals();
    }
    public function initComponents():void
    {
        for (var i:int = 0; i < components.length; ++i)
        {
            components[i].com.init();
        }
        //Post init
        if (initEnd) {
            for (var j:int = 0; j < initEnd.length; ++j)
            {
                initEnd[j]();
            }
        }
    }

    public function update():void {
        if (!enabled) return;
        for (var i:int = 0; i < components.length; ++i)
        {
            components[i].com.update();
        }
        //Child entities
        for (var j:int = 0; j < entities.length; ++j) entities[j].update();
        for (j = 0; j < entities.length; ++j) entities[j].postUpdate();

    }
    public function postUpdate():void {
        if (!enabled) return;
        if (postUpdateVec) {
            for (var j:int = 0; j < postUpdateVec.length; ++j)
            {
                postUpdateVec[j].func();
            }
        }
    }

    public function addComponent(compObj:Component, index:int = 0):void {
        components.push(new OneComponent(compObj, index));
        shellSort(components);
    }

    public function addPostUpdate(func:Function, index:int = 0):void {
        if (!postUpdateVec) postUpdateVec = new Vector.<PostUpdateFunc>();
        postUpdateVec.push(new PostUpdateFunc(func, index));
        shellSort(postUpdateVec);
    }

    public function addOnInitEnd(func:Function):void
    {
        if (!initEnd) initEnd = new Vector.<Function>();
        initEnd.push(func);
    }
    public function addChildEntity(ent:Entity):void {
        entities.push(ent);
    }
    public function getChildEntities():Vector.<Entity> {
        return entities;
    }
    public function registerLocal(func:Function, group:String = null):void {
        signals.add(func, group);
    }
    public function send(msg:String, data:Object = null, group:String = null): void {
        signals.dispatchSignal(msg,  data, group);
    }

    public function getComponent(compClass:Class):Component {
        for (var j:int = 0; j < components.length; ++j)
        {
            if (components[j].com is compClass) return components[j].com;
        }
        return null;
    }

    public function getComponents(compClass:Class):Array {
        var retArr:Array = [];
        for (var j:int = 0; j < components.length; ++j)
        {
            if (components[j].com is compClass) retArr.push(components[j].com);
        }
        return retArr;
    }
    public function haveComponent(compClass:Class):Boolean
    {
        if (getComponent(compClass)) return true;
        else return false;
    }
    public function disableComponents(compArr:Vector.<Class> = null):void {
        if (compArr) {
            //Disable selected
            for (var j:int = 0; j < components.length; ++j)
            {
                for (var i:int = 0; i < compArr.length; ++i)
                {
                    if (components[j].com is compArr[i]) {
                        components[j].com.disable(); //trace("com dis");
                        break;
                    }
                }
            }
        } else {
            //Disable all
            for (var jj:int = 0; jj < components.length; ++j)
            {
                components[jj].com.disable();
            }
        }
    }
    public function disableComponentsByClass(compClass:Class):void {
        for (var j:int = 0; j < components.length; ++j)
            if (components[j].com is compClass) components[j].com.disable();
    }
    public function enableComponentsByClass(compClass:Class):void {
        for (var j:int = 0; j < components.length; ++j)
            if (components[j].com is compClass) components[j].com.enable();
    }
    public function enable():void {
        enabled = true;
    }
    public function disable():void {
        enabled = false;
    }
    override public function remove():void {
        super.remove();
        //
        for (var j:int = 0; j < components.length; ++j) components[j].com.remove();
        for (j = 0; j < entities.length; ++j) entities[j].remove();
        //
        GLB.engine.removeEntity(this);
    }

    //Help functions
    private function sortComponents():void
    {

    }

    final private function shellSort(data:*): void
    {
        var n:int = data.length;
        var inc:int = int(n/2);
        while(inc) {
            for(var i:int=inc; i<n; i++) {
                var temp:* = data[i], j:int = i;
                while(j >= inc && data[int(j - inc)].index > temp.index) {
                    data[j] = data[int(j - inc)];
                    j = int(j - inc);
                }
                data[j] = temp
            }
            inc = int(inc / 2.2);
        }
    }

}
}

import org.volodko.engine.Component;

class PostUpdateFunc {

    public var func:Function;
    public var index:int;

    public function PostUpdateFunc(func:Function, index:int) {
        this.func = func;
        this.index = index;
    }
}

class OneComponent {

    public var com:Component;
    public var index:int;

    public function OneComponent(com:Component, index:int) {
        this.com = com;
        this.index = index;
    }
}