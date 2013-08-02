package org.volodko.engine {

public class MsgVO {
    // Global messages

    //State
    static public const STATE:String = "STATE";
    static public const STATE_END:String = "STATE_END";

    static public const LOG:String = "log";
    static public const LOG_TEMP:String = "log_temp";

    //Pause
    static public const PAUSE:String = "PAUSE";
    static public const PAUSE_END:String = "PAUSE_END";
    static public const PAUSE_SHOW:String = "PAUSE_SHOW";

    //Buttons
    static public const BUTTON_OUT:String = "button_out";
    static public const BUTTON_OVER:String = "button_over";
    static public const BUTTON_DOWN:String = "button_down";
    static public const BUTTON_UP:String = "button_up";
    static public const BUTTON_CLICK:String = "button_clicked";

    //Highlight
    static public const HIGHLIGHT:String = "HIGHLIGHT";
    static public const HIGHLIGHT_END:String = "HIGHLIGHT_END";
    //Blink
    static public const BLINK:String = "BLINK";
    static public const BLINK_END:String = "BLINK_END";

    //Show hide
    static public const HIDE:String = "HIDE";
    static public const SHOW:String = "SHOW";

    //Slectable
    static public const SELECT_END:String = "SELECT_END";
    static public const SELECTED:String = "SELECTED";


    //Keys controller
    static public const GO_LEFT:String = "GO_LEFT";
    static public const GO_RIGHT:String = "GO_RIGHT";
    static public const GO_UP:String = "GO_UP";
    static public const GO_DOWN:String = "GO_DOWN";

    //Pixel display
    public static const PIX_DISPLAY_UP:String = "PIX_DISPLAY_UP";
    public static const PIX_DISPLAY_DOWN:String = "PIX_DISPLAY_DOWN";
    public static const PIX_DISPLAY_OVER:String = "PIX_DISPLAY_OVER";
    public static const PIX_DISPLAY_OUT:String = "PIX_DISPLAY_OUT";

    //Console
    public static const CONSOLE_COMMAND:String = "CONSOLE_COMMAND";

    //
    public function MsgVO() {

    }

}

}