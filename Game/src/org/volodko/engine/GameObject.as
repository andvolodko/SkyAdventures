/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 10.04.12
 * Time: 10:10
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
public class GameObject {
    
    private var signals:Vector.<Object> = new Vector.<Object>();
    
    public function GameObject() {
    }
    public function dispatch(message:String, data:Object = null, group:String = null):void {
        if(GLB.signals) GLB.signals.dispatchSignal(message, data, group);
    }
    public function register(func:Function, group:String = null):void {
        if(GLB.signals) {
            signals.push({func:func, group:group});
            GLB.signals.add(func, group);
        }
    }
    public function remove():void {
        for each (var object:Object in signals) {
            GLB.signals.removeSignal(object.func, object.group);
        }
    }
}
}
