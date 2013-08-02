/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 29.04.12
 * Time: 2:40
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.entities.triggers {
public class TriggerVO {

    //Trigger task types
    public static const TASK_SHAKE:String = "shake";
    public static const TASK_SOUND_EFFECT:String = "sound_effect";
    public static const TASK_SOUND_CHANGE:String = "sound_change";

    //Shake types
    public static const SHAKE_TYPE_SMALL:String = "small";
    public static const SHAKE_TYPE_BIG:String = "big";

    //Points delim
    public static const POINTS_DELIM:String = " ";
    public static const POINT_VAL_DELIM:String = ",";

    //
    public function TriggerVO() {
    }
}
}
