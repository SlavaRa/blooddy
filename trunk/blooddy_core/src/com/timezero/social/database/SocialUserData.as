package com.timezero.social.database {

	import com.timezero.platform.database.DataContainer;

	public class SocialUserData extends DataContainer {

		public function SocialUserData(id:String) {
			super();
			this.id = id;
		}
		
		public var id:String;
		
		public var firstName:String;
		
		public var lastName:String;
		
		public var nickName:String;
		
		public var sex:int = -1;
		
		public var birthday:Date;
		
		public var photo:String;
		
		public var mediumPhoto:String;
		
		public var bigPhoto:String;
		
		public var url:String;
		

	}

}