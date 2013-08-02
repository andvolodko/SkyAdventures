/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 17.04.12
 * Time: 18:50
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.game.helpers {
import org.volodko.game.scenarios.Level1;

public class LevelVO {

    static public const CHILD_TILESET:String = "tileset";
    static public const CHILD_LAYER:String = "layer";
    static public const CHILD_OBJECTGROUP:String = "objectgroup";

    //Layer properties
    static public const PROP_GRAPHIC:String = "graphic";
    static public const PROP_TYPE:String = "type";
    static public const PROP_SCENARIO:String = "scenario";

    //Layer type variants
    static public const LAYER_GRAPHIC:String = "graphic";
    static public const LAYER_BRICKS:String = "bricks";
    static public const LAYER_PATH:String = "path";

    //Entity types
    static public const TYPE_HERO:String = "hero";
    static public const TYPE_ENEMY:String = "enemy";
    static public const TYPE_TRIGGER:String = "trigger";

    static public function getClass(classString:String):Class {
        switch(classString) {
            case "Level1": return Level1; break;
            default:
                trace("ERROR: Class not found "+classString);
                return null;
        }
    }
    
    public function LevelVO() {
    }
}
}
