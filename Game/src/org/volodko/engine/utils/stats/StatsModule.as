/**
 * Created by IntelliJ IDEA.
 * User: Andrey
 * Date: 14.04.12
 * Time: 1:41
 * To change this template use File | Settings | File Templates.
 */
package org.volodko.engine.utils.stats {
import org.volodko.engine.GLB;
import org.volodko.engine.Module;

public class StatsModule extends Module {
    private var stats:Stats;
    public function StatsModule() {
        init();
    }

    private function init():void {
        GLB.stage.addChild(stats = new Stats(50, 0, 0, false, true, false, 1));
        stats.alpha = 0.5;
        stats.alignRight();
    }


}
}
