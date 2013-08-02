/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 09.04.12
 * Time: 1:34
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.display.Stage;

public class GLB {
    //------------------ Static vars ------------
    static public var width:int;
    static public var height:int;
    //
    static public var oldmx:int; //mouse position x
    static public var oldmy:int; //mouse position y
    static public var mx:int; //mouse position x
    static public var my:int; //mouse position y
    //
    static public var elapsed:Number = 0;
    static public var frameTime:Number;
    static public var frames:Number = 0;
    static public var totalElapsed:Number = 0;
    static public var stage:Stage;
    static public var engine:Engine;
    //
    public static var signals:Signals; //Global signals

    public function GLB() {
    }
}
}
