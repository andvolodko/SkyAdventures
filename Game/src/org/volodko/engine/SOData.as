/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 10.04.12
 * Time: 12:02
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
import flash.net.SharedObject;

public class SOData extends Module {
    //
    private var soName:String;
    private var soClear:Object;
    //
    private var mySharedObject:SharedObject = null;
    private var userData:Object;
    //
    public function SOData(soName:String, soClear:Object) {
        this.soName = soName;
        this.soClear = soClear;
        init();
        //getClearData(); //Test
    }

    private function init():void {
        refreshShared();
        CONFIG::debug {
            register(commandsListener, GroupsVO.DEBUG);
        }
        //TODO: Add slots
    }

    public function get():Object {
        return userData;
    }
    public function saveNow():void {
        sharedFlush();
    }

    public function sharedFlush():void {
        mySharedObject.data.arr = userData;
        mySharedObject.flush();
    }
    public function clear():void {
        mySharedObject.data.arr = getClearData();
        userData = mySharedObject.data.arr;
    }
    private function refreshShared():void {
        if (!mySharedObject) mySharedObject = SharedObject.getLocal(soName);
        if (!mySharedObject.data.hasOwnProperty("arr"))
            mySharedObject.data.arr = getClearData();
        userData = mySharedObject.data.arr;
        //dispatch("trace", userData);
    }
    private function getClearData():Object
    {
        var retObj:Object = {};
        for (var val:* in soClear) {
            //trace('   [' + typeof(soClear[val]) + '] ' + val + ' => ' + soClear[val]);
            if(typeof(soClear[val]) == "object") retObj[val] = getClearIn(soClear[val]);
            else retObj[val] = soClear[val];
        }
        //trace("get clear data");
        //dispatch("trace", retObj);
        return retObj;
    }

    private function getClearIn(soClearIn:Object):Object {
        var retObj:Object = {};
        for (var val:* in soClearIn) {
            //trace('      [' + typeof(soClearIn[val]) + '] ' + val + ' => ' + soClearIn[val]);
            if(typeof(soClearIn[val]) == "object") retObj = getClearIn(soClearIn[val]);
            else retObj = soClearIn[val];
        }
        return retObj;
    }

    //------------------------- Commands --------------------------
    private function commandsListener(msg:String, data:Object):void {
        switch (msg) {
            case MsgVO.CONSOLE_COMMAND:
                switch(ConsoleCmd(data).commandName) {
                    case CmdVO.SO_CLEAR:
                            clear();
                        break;
                }
                break;
        }
    }

}
}
