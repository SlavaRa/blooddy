package by.blooddy.core.logging {

	public class InfoLogger extends Logger {

		public function InfoLogger(maxLength:uint=3, maxTime:uint=10E3) {
			super( maxLength, maxTime );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addInfo(messege:String, type:uint=0):void {
			super.addLog( new InfoLog( messege, type ) );
		}

	}

}