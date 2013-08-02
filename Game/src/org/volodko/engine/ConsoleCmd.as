/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 20.04.12
 * Time: 22:40
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
public class ConsoleCmd {
    public var commandName:String;
    public var commandParams:Array;

    public function ConsoleCmd(cmdStr:String):void {
        cmdStr = trim(cmdStr);
        commandParams = cmdStr.split(" ");
        commandName = commandParams[0];
        commandParams = commandParams.slice(0, 1);
    }

    private function trim(s:String):String {
        return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
    }
}
}
