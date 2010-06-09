////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
extern class JPEGTable {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *	   1:	YTable						[1]{64}
	 *	  65:	UVTable						[1]{64}
	 *	 130:	fdtbl_Y						[8]{64}
	 *	 642:	fdtbl_UV					[8]{64}
	 *
	 *	1154:	0
	 *	1155:	std_dc_luminance_nrcodes	[1]{16}
	 *	1172:	std_dc_luminance_values		[1]{12}
	 *	1184:	0
	 *	1185:	std_ac_luminance_nrcodes	[1]{16}
	 *	1201:	std_ac_luminance_values		[1]{162}
	 *	1363:	0
	 *	1364:	std_dc_chrominance_nrcodes	[1]{16}
	 *	1380:	std_dc_chrominance_values	[1]{12}
	 *	1392:	0
	 *	1393:	std_ac_chrominance_nrcodes	[1]{16}
	 *	1409:	std_ac_chrominance_values	[1]{162}
	 *	1571:	YDC_HT						[1,3]{12}
	 *	1583:	YAC_HT						[1,3]{162}
	 *	1745:	UVDC_HT						[1,3]{12}
	 *	1757:	UVAC_HT						[1,3]{162}
	 *
	 *	1919:
	 */
	public static function getTable(?quality:UInt=60):ByteArray;
	
}