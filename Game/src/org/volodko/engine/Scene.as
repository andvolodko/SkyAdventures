/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 23.03.12
 * Time: 23:49
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;

import org.volodko.engine.interfaces.IUpdatable;

public class Scene extends Sprite implements IUpdatable {
    //
    protected var graphicClip:DisplayObjectContainer;
    protected var graphicClipClass:Class;
    //
    protected var entities:Vector.<Entity>;
    protected var entitiesNoUpdate:Vector.<Entity>;
    protected var removeEntities:Vector.<Entity>;
    //
    public function Scene(graphicClipClass:Class) {
        this.graphicClipClass = graphicClipClass;
        super();
        if (stage) initialize();
        else addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    protected function initialize(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, initialize);
        //
        graphicClip = new graphicClipClass() as DisplayObjectContainer;
        addChild(graphicClip);
        //
        entities = new Vector.<Entity>();
        entitiesNoUpdate = new Vector.<Entity>();
        removeEntities = new Vector.<Entity>();
    }

    public function dispatch(message:String, data:Object = null, group:String = null):void {
        if(GLB.signals) GLB.signals.dispatchSignal(message, data, group);
    }

    public function update():void {
        //
        for (var i:int = 0; i < entities.length; ++i) {
            entities[i].update();
        }
        for (i = 0; i < entities.length; ++i) {
            entities[i].postUpdate();
        }
        //Check entities to remove
        checkEntitiesToRemove();
    }

    public function postUpdate():void {
    }

    public function addEntity(ent:Entity):void {
        entities.push(ent);
    }
    public function addEntityNoUpdate(ent:Entity):void {
        entitiesNoUpdate.push(ent);
    }
    public function removeEntity(ent:Entity):void {
        removeEntities.push(ent);
    }


    public function removeGameObject(gameObjLoc:Entity):Boolean
    {
        for (var i:int = 0; i < entities.length; ++i)
        {
            if (entities[i] == gameObjLoc) {
                entities[i].remove();
                entities.splice(i, 1);
                return true;
            }
        }
        return false;
    }

    public function checkEntitiesToRemove():void
    {
        while(removeEntities.length > 0) {
            removeGameObject(removeEntities.pop());
        }
    }

    public function remove():void {
        for (var i:int = 0; i < entities.length; ++i)
        {
            entities[i].remove();
        }
        for (i = 0; i < entitiesNoUpdate.length; ++i) {
            entitiesNoUpdate[i].remove();
        }
    }

}
}
