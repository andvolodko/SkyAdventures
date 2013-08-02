/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 09.04.12
 * Time: 1:46
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import org.volodko.engine.GameObject;
import org.volodko.engine.interfaces.IEnableDisable;
import org.volodko.engine.interfaces.IUpdatable;

public class Component extends GameObject implements IUpdatable, IEnableDisable{
    //
    protected var entity:Entity;
    protected var enabled:Boolean = true;
    //
    public function Component(entityLoc:Entity) {
        entity = entityLoc;
        addGlobalComponent(this);
    }
    public function init():void {

    }

    public function postUpdate():void {
    }

    public function update():void {
    }

    public function enable():void {
        enabled = true;
    }
    public function disable():void {
        enabled = false;
    }
    public function isEnabled():Boolean {
        return enabled;
    }
    public function send(msg:String, data:Object = null, group:String = null): void {
        entity.send(msg, data, group);
    }
    /*
     * Get global components
     */
    public function addGlobalComponent(comp:Component):void {
        GLB.engine.addComponent(comp);
    }
    public function removeGlobalComponent(comp:Component):void {
        GLB.engine.removeComponent(comp);
    }
    public function getGlobalComponents(compClass:Class):Array {
        return GLB.engine.getComponents(compClass);
    }
    /*
     * Get local components
     */
    public function getComponent(compClass:Class):Component {
        return entity.getComponent(compClass);
    }
    public function getComponents(compClass:Class):Array {
        return entity.getComponents(compClass);
    }
    public function haveComponent(compClass:Class):Boolean {
        return entity.haveComponent(compClass);
    }

    /*
     * Remove
     */
    override public function remove():void {
        super.remove();
        //
        removeGlobalComponent(this);
    }
}
}
