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
	 *	     1:	YTable						[1]{64}
	 *	    65:	UVTable						[1]{64}
	 *	   130:	fdtbl_Y						[8]{64}
	 *	   642:	fdtbl_UV					[8]{64}
	 * 	  1154:	0							[1]{1}
	 *	  1155:	std_dc_luminance_nrcodes	[1]{16}
	 *	  1171:	std_dc_luminance_values		[1]{12}
	 *	  1183:	0							[1]{1}
	 *	  1184:	std_ac_luminance_nrcodes	[1]{16}
	 *	  1200:	std_ac_luminance_values		[1]{162}
	 *	  1362:	0							[1]{1}
	 *	  1363:	std_dc_chrominance_nrcodes	[1]{16}
	 *	  1379:	std_dc_chrominance_values	[1]{12}
	 *	  1391:	0							[1]{1}
	 *	  1392:	std_ac_chrominance_nrcodes	[1]{16}
	 *	  1408:	std_ac_chrominance_values	[1]{162}
	 *	  1570:	YDC_HT						[1,2]{12}
	 *	  1606:	YAC_HT						[1,2]{251}
	 *	  2359:	UVDC_HT						[1,2]{12}
	 *	  2395:	UVAC_HT						[1,2]{251}
	 *	  3148:	cat							[1,2]{65534}
	 *	199753:
	 */
	public static function getTable(?quality:UInt=60):ByteArray;
	
}