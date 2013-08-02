/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 08.04.12
 * Time: 21:54
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.threads {
import flash.utils.getTimer;

import org.volodko.engine.GroupsVO;

import org.volodko.engine.Module;
import org.volodko.engine.MsgVO;

public class Threads extends Module {
    
    private var threads:Vector.<ThreadData> = new Vector.<ThreadData>();
    //
    private var threadTime:Number = 1/90;
    private var finishFuncs:Vector.<Function> = new Vector.<Function>();
    //
    public function Threads() {
    }
    
    public function addThread(jobFunc:Function, priority:Number = 1, onEnd:Function = null, threadName:String = "unnamed"):void {
        threads.push(new ThreadData(jobFunc, priority, onEnd, threadName));
    }

    override public function update():void {
        super.update();
        //
        //Finish functions
        if(threads.length == 0) {
            while(finishFuncs.length > 0) {
                var tmpFunc:Function = finishFuncs.pop();
                tmpFunc();
            }
        }
        //
        var startTime:Number = getTimer();
        var doJob:Boolean = false;
        for(var i:int = 0; i < threads.length; i++)
        {
            var threadStartTime:Number = getTimer();
            doJob = false;
            while(threads[i].makeJob()) {
                doJob = true;
                var secondTime:Number = getTimer();
                //
                if((secondTime - startTime)/1000 >= threadTime * threads[i].getPriority()) {
                    CONFIG::debug {
                        threads[i].addTime((secondTime - threadStartTime)/1000);
                    }
                    break;
                }
            }
            //Thread finished
            if(!doJob) {
                threads[i].onEndCall();
                CONFIG::debug {
                    CONFIG::debug { dispatch(MsgVO.LOG, "Thread '"+threads[i].getName()+"' finished: "+threads[i].getTime()+" sec.", GroupsVO.DEBUG); }
                }
                threads.splice(i, 1); --i;
            }
            //
            secondTime = getTimer();
            if((secondTime - startTime)/1000 >= threadTime) break;
        }
    }

    public function onFinishAdd(finishFunc:Function):void {
        finishFuncs.push(finishFunc);
    }
}
}

internal class ThreadData {
    private var jobFunc:Function;
    private var priority:Number;
    private var onEnd:Function;
    private var time:Number = 0;
    private var name:String;
    public function ThreadData(jobFunc:Function, priority:Number = 1, onEnd:Function = null, name:String = null) {
        this.jobFunc = jobFunc;
        this.priority = priority;
        this.onEnd = onEnd;
        this.name = name;
    }
    /*
    Return false if job not finished
     */
    public function makeJob():Boolean {
        return jobFunc();
    }
    public function getPriority():Number {
        return priority;
    }
    public function onEndCall():void {
        if(onEnd != null) onEnd();
    }
    public function getName():String {
        return name;
    }
    public function addTime(val:Number):void {
        time += val;
    }
    public function getTime():Number {
        return time;
    }
}