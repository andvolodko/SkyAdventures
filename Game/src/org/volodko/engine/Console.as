package org.volodko.engine {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

/**
 * ...
 * @author Volodko Andrey
 */
public class Console extends Module {
    static private const PADDING:int = 20;
    static private const INPUT_BG_COLOR:uint = 0x5580FF80;
    static private const INPUT_TEXT_COLOR:uint = 0x00FF40;
    static private const INPUT_BORDER_COLOR:uint = 0x000000;
    static private const INPUT_DEF_TEXT:String = "Type command ...";
    static private const LOG_TEXT_COLOR:uint = 0xFFFFFF;
    static private const UPDATE_FRAME:int = 5; //Every 5 frame
    static private const LAST_LOG_LINES:int = 18;

    //
    private var sprite:Sprite;
    private var input:TextField;
    private var log:TextField;
    //
    private var tempLog:Vector.<String> = new Vector.<String>();
    private var logStrings:Vector.<String> = new Vector.<String>();
    private var cmdStrings:Vector.<String> = new Vector.<String>();
    private var cmdIndex:int = 0;
    private var logIndex:int = 0;
    //
    private var keys:Keys;
    private var date:Date;

    public function Console() {
        super();
        init();
    }

    public function init():void {
        //
        keys = Keys(GLB.engine.getModule(Keys));
        register(signalListener, GroupsVO.DEBUG);
        date = new Date();
        //
        sprite = new Sprite();
        sprite.graphics.beginFill(0x111111, 1);
        sprite.graphics.drawRect(0, 0, GLB.width, GLB.height);
        sprite.graphics.endFill();
        GLB.stage.addChild(sprite);
        //Input label
        input = new TextField();
        input.x = PADDING;
        input.y = GLB.height - PADDING * 2;
        input.width = GLB.width - PADDING * 2;
        input.height = PADDING;
        input.border = true;
        input.borderColor = INPUT_BORDER_COLOR;
        input.selectable = true;
        input.multiline = false;
        input.textColor = INPUT_TEXT_COLOR;
        input.defaultTextFormat = new TextFormat("Arial", 11, null, null, null, null, null, null, null, null, null, 3, null);
        input.type = TextFieldType.INPUT;
        input.text = INPUT_DEF_TEXT;
        input.addEventListener(KeyboardEvent.KEY_DOWN, down);
        input.addEventListener(FocusEvent.FOCUS_IN, focus);
        input.addEventListener(FocusEvent.FOCUS_OUT, focusEnd);
        sprite.addChild(input);
        //Log label
        log = new TextField();
        log.x = PADDING;
        log.y = PADDING;
        log.width = GLB.width - PADDING * 2;
        log.height = GLB.height - PADDING * 4;
        log.border = true;
        log.borderColor = INPUT_BORDER_COLOR;
        log.selectable = true;
        log.textColor = LOG_TEXT_COLOR;
        log.defaultTextFormat = new TextFormat("Arial", 11);
        log.type = TextFieldType.DYNAMIC;
        log.text = "";
        log.multiline = true;
        log.wordWrap = true;
        log.addEventListener(MouseEvent.MOUSE_WHEEL, logScroll);
        sprite.addChild(log);
        //
        hide();
    }

    override public function update():void {
        super.update();
        //
        if (sprite.visible && GLB.frames % UPDATE_FRAME == 1) {
            //System text
            var htmlStr:String = "Memory: <b>" + ((System.totalMemory / 1024) / 1000) + " MB</b>\n" +
                    "Frames: <b>" + GLB.frames + "</b>\n" +
                    "Elapsed: <b>" + GLB.elapsed + "</b>\n" +
                    "Current FPS: <b>" + int(1 / GLB.elapsed) + "</b>\n" +
                    "Average FPS: <b>" + int(GLB.frames / GLB.totalElapsed) + "</b>" +
                    "\n-----------------------------------------------------------------------------------------------------------------------------------------------------------\n";
            //Temporary log
            htmlStr += "<font color='#00ffff'>";
            for (var i:int = 0; i < tempLog.length; ++i) {
                htmlStr += tempLog[i] + "  |  ";
            }
            htmlStr += "</font>";
            htmlStr += "\n-----------------------------------------------------------------------------------------------------------------------------------------------------------\n";
            tempLog = new Vector.<String>();
            //Log lines
            var startLine:int = logIndex + logStrings.length - 1 - LAST_LOG_LINES;
            if (startLine < 0) startLine = 0;
            if (startLine >= logStrings.length-1) startLine = logStrings.length-1;
            htmlStr += "<font color='#9acd32'>";
            for (i = startLine; i < logStrings.length; ++i) {
                htmlStr += logStrings[i] + "\n";
            }
            htmlStr += "</font>";
            //
            log.htmlText = htmlStr;
            //log.text += GLB.stage.frameRate;
        } else {
            //Clear
            tempLog = new Vector.<String>();
        }

        //
        if (keys.justReleased("CONSOLE")) {
            if (sprite.visible) hide();
            else show();
        }
    }

    private function show():void {
        cmdIndex = 0;
        GLB.stage.focus = input;
        input.text = input.text.replace("`","");
        //
        if (sprite.parent) sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
        //
        sprite.visible = true;
    }

    private function hide():void {
        sprite.visible = false;
    }

    private function enterCommand(cmd:String):void {
        input.text = "";
        //
        cmdStrings.push(cmd);
        signalListener(MsgVO.LOG, "<font color='#00FF40'>" + cmd + "</font>");
        dispatch(MsgVO.CONSOLE_COMMAND, new ConsoleCmd(cmd), GroupsVO.DEBUG);
    }

    private function signalListener(msg:String, data:Object):void {
        switch (msg) {
            case MsgVO.LOG:
                    addLogString(data + "    " + getTime());
                break;
            case MsgVO.LOG_TEMP:
                tempLog.push(data);
                break;
            //Commands
                case MsgVO.CONSOLE_COMMAND:
                        switch(ConsoleCmd(data).commandName) {
                            case CmdVO.CLEAR:
                                var lastCmd:String = logStrings.pop();
                                logStrings = new Vector.<String>();
                                addLogString(lastCmd);
                            break;
                        }
                break;
        }
    }

    private function addLogString(s:String):void {
        logStrings.push(s);
        logIndex = logStrings.length - 1 - LAST_LOG_LINES;
    }

    private function getTime():String {
        //var time:Number = getTimer();
        //return TimeUtil.formatTime(getTimer());
        return "<font color='#a9a9a9'>" + date.toTimeString() + "</font>";
    }

    //--------------- Events ---------------------
    private function down(e:KeyboardEvent):void {
        //trace(e.charCode, e.keyCode);
        switch (e.keyCode) {
            //Enter
            case 13:
                //trace("enter");
                if (input.text.length > 0) enterCommand(input.text);
                break;
            //Up
            case 38:
                //trace("up");
                if (cmdStrings.length > 0) {
                    cmdIndex--;
                    if (cmdIndex < 0) cmdIndex = cmdStrings.length - 1;
                    input.text = cmdStrings[cmdIndex];
                }
                break;
            //Down
            case 40:
                //trace("down");
                if (cmdStrings.length > 0) {
                    input.text = cmdStrings[cmdIndex];
                    cmdIndex++;
                    if (cmdIndex >= cmdStrings.length) cmdIndex = 0;
                }
                break;
            //default: trace(e.keyCode);
        }
    }

    private function focusEnd(e:FocusEvent):void {
        if (input.text.length == 0) input.text = INPUT_DEF_TEXT;
    }

    private function focus(e:FocusEvent):void {
        if (input.text.indexOf(INPUT_DEF_TEXT) >= 0) input.text = "";
    }

    private function logScroll(event:MouseEvent):void {
        if(event.delta > 0) {
            --logIndex; 
        } else {
            ++logIndex; 
        }
        //Check
        if(logIndex < -logStrings.length + LAST_LOG_LINES) logIndex = -logStrings.length + LAST_LOG_LINES;
        if(logIndex > logStrings.length - 1 - LAST_LOG_LINES) logIndex = logStrings.length - 1 - LAST_LOG_LINES;
        //TODO Scroll minor bug
        //trace(logIndex);
    }
}

}
