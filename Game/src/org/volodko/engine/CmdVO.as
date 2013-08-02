/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 20.04.12
 * Time: 4:26
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine {
public class CmdVO {

    //Log
    static public const CLEAR:String = "clear";

    //States
    static public const RESET:String = "reset";

    //Shared cmds
    static public const SO_CLEAR:String = "so_clear";

    //Physic
    static public const PH_SHOW:String = "ph_show";
    static public const PH_CLEAR:String = "ph_clear";

    //Cache
    static public const CACHE_GEN:String = "cache_gen";
    static public const CACHE_CLEAR:String = "cache_clear";

    public function CmdVO() {
    }
}
}
