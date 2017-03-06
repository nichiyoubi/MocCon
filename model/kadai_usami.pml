/*********************************************************************
 * Title : MocCon Model
 * Team  : Hayakawa, Usami
 * Date  : 2017/03/12
 *********************************************************************/
/*
1234567890123456789012345678901234567890123456789012345678901234567890
*/

mtype = { TAIKI, HATSU, CHAKU, TSUUWA, INIT, WAIT,
          a_hatsu, a_outou, a_chuushi, a_kyohi, a_shuuryou,
	  b_hatsu, b_outou, b_chuushi, b_kyohi, b_shuuryou };


chan UserComm = [0] of { mtype };
chan TaComm = [0] of { mtype };
chan TbComm = [0] of { mtype };
chan ch_ope = [0] of { mtype };

mtype recv_unit;     /* 受信装置の状態 */
mtype reset_unit;    /* リセット装置の状態 */


/*********************************************************************
 * 通信端末
 *********************************************************************/
active proctype com_unit()
{
	recv_unit = TAIKI;	/** 受信装置の初期化 **/
	reset_unit = INIT;	/** リセット装置の初期化 **/
	
	byte mtx = 0;

	do
	::
		do
		::recv_unit == TAIKI;
			if
			::ch_ope ? a_hatsu -> recv_unit = HATSU;
			::ch_ope ? b_hatsu -> recv_unit = CHAKU;
				 /** ログの処理 **/
			fi;
		::recv_unit == HATSU;
			if
			::ch_ope ? a_chuushi -> recv_unit = TAIKI;
			::ch_ope ? b_outou -> recv_unit = TSUUWA; mtx = 1;
			::ch_ope ? b_kyohi -> recv_unit = TAIKI;
				 /** ログの処理 **/
			fi;
		::recv_unit == CHAKU;
			if
			::ch_ope ? a_outou -> TSUUWA;
				 if
				 ::mtx == 0 -> mtx = 1;
				 ::mtx == 1 -> mtx = 2;
				 fi;
			::ch_ope ? a_kyohi ->
				 if
				 ::mtx == 0 -> recv_unit = TAIKI;
				 ::mtx == 1 -> recv_unit = TSUUWA;
				 fi;
				 /** ログの処理 **/
			::ch_ope ? a_shuuryou ->
				 if
				 ::mtx == 1 -> mtx = 0;
				 ::mtx == 2 -> mtx = 1;
				 fi;
			::ch_ope ? b_chuushi -> 
				 if
				 ::mtx == 0 -> recv_unit = TAIKI;
				 ::mtx == 1 -> recv_unit = TSUUWA;
				 fi;
			::ch_ope ? b_shuuryou ->
				 if
				 ::mtx == 1 -> mtx = 0;
				 ::mtx == 2 -> mtx = 1;
				 fi;
			fi;
		::recv_unit == TSUUWA;
			if
			::ch_ope ? a_shuuryou ->
				 if
				 ::mtx == 1 -> recv_unit = TAIKI;
				 fi;
				 if
				 ::mtx == 1 -> mtx = 0;
				 ::mtx == 2 -> mtx = 1;
				 fi;
			::ch_ope ? b_hatsu -> skip; /** **/
				 if
				 ::mtx == 1 -> recv_unit = CHAKU;
				 fi;
				 /** ログの処理 **/
			::ch_ope ? b_shuuryou ->
				 if
				 ::mtx == 1 -> recv_unit = TAIKI;
				 fi;
				 if
				 ::mtx == 1 -> mtx = 0;
				 ::mtx == 2 -> mtx = 1;
				 fi;
			fi;
		od;
		do
		::reset_unit == INIT -> reset_unit = WAIT;
		::reset_unit == WAIT -> skip;
		od;
	od;
}


