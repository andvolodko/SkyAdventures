package org.volodko.engine
{
	import com.junkbyte.console.Cc;
	import net.jpauclair.FlashPreloadProfiler;

import org.volodko.engine.Module;

public class Profiler extends Module
	{
		
		public function Profiler() 
		{
			super();
			init();
		}
		private function init():void {
			//

			CONFIG::debug {
                GLB.stage.addChild(new FlashPreloadProfiler());
				/* if (Glb.debug) {
					Cc.config.commandLineAllowed = true;
					Cc.startOnStage(NNLG.engine, "");
				} */
			}
		}
	}

}