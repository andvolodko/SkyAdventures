/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 09.04.12
 * Time: 8:16
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.helpers {
public class GameGLB {

    //Start with sounds
    static public var noSounds:Boolean = false;

    //Cursor
    public static const CUSTOM_CURSOR:Boolean = true;

    //Physic properties
    static public const GRAVITY_X:Number = 0;
    static public const GRAVITY_Y:Number = 600;
    //
    static public const smoothingBD:Boolean = true;
    //
    static public const mapMargin:int = 100;
    //
    //SO properties
    static public var sharedObjectName:String = "robot_robin";
    static public var soClear:Object = {
        system:{
            tips:true,
            sounds: true,
            music: true
        },
        hero:{
            ammo:0,
            last_ammo:0,
            health:0,
            score:0,
            cash:0,
            total_score:0,
            total_cash:0,
            time:0,
            lives:5,
            level:1,
            level_open:1,
            killed:0,
            headshots:0
        },
        medals:{
            first_blood:false,
            head_shot:false,
            killing_spree:false,
            test:{
                test1:1,
                test2:2
            },
            engineer:false,
            assassin:false,
            infiltrator:false
        }
    };

    //
    public function GameGLB() {
    }

    static public function noSoundFunc():void {
        noSounds = !noSounds;
    }
}
}
