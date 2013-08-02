/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 07.04.12
 * Time: 10:24
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.utils.Dictionary;

public class Signals extends Module{

    private var functions:Vector.<Function> = new Vector.<Function>();
    private var dictionary:Dictionary = new Dictionary(true);

    public function Signals() {
    }

    public function dispatchSignal(message:String, data:Object = null, group:String = null):void {
        var i:int;
        if(group){
            if(dictionary[group]) {
                var funcVec:Vector.<Function> = dictionary[group];
                for (i = 0; i < funcVec.length; i++) {
                    funcVec[i](message, data);
                }
            }
        } else 
        for (i = 0; i < functions.length; i++) {
            functions[i](message,data);
        }
    }

    public function add(func:Function, group:String = null):void {
        if(group) {
            checkGroup(group);
            dictionary[group].push(func);
        }
        else functions.push(func);
    }

    private function checkGroup(group:String):void {
        if(!dictionary[group]) dictionary[group] = new Vector.<Function>();
    }

    public function removeSignal(func:Function, group:String = null):void {
        var i:int;
        if(group) {
            if(dictionary[group]) {
                var funcVec:Vector.<Function> = dictionary[group];
                for (i = 0; i < funcVec.length; i++) {
                    if(func == funcVec[i]) {
                        funcVec.splice(i, 1);
                        i--;
                    }
                }
            }
        } else
        for (i = 0; i < functions.length; i++) {
            var obj:Function = functions[i];
            if(func == obj) {
                functions.splice(i, 1);
                i--;
            }
        }
    }

    public function removeAll():void {
        functions = new Vector.<Function>();
        for (var k:Object in dictionary) {
            dictionary[k] = null;
        }
    }
}
}
