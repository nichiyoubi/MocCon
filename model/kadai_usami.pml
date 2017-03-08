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
mtype = { CLEAR, SAVE };

chan ch_ope = [0] of { mtype };	/* ユーザー操作用チャネル */
chan ch_com = [0] of { mtype };	/* 他通信端末との通信用チャネル */

mtype recv_unit;     /* 受信装置の状態 */
mtype reset_unit;    /* リセット装置の状態 */

byte mtx = 0;			/** 同時接続数 (0, 1, 2) **/
byte CHAKU_ST = CLEAR;		/** 着信履歴 (CLEAR/SAVE) **/
byte KYOHI_1_ST = CLEAR;	/** 自拒否履歴 (CLEAR/SAVE) **/
byte KYOHI_2_ST = CLEAR;	/** 他拒否履歴 (CLEAR/SAVE) **/
int  Chaku_log = 0;		/** 着信履歴 5000件/10000件 -> 50件/100件に縮退 **/
int  Kyohi_1_log = 0;		/** 拒否ログ数 1500件/3000件 -> 15件/30件に縮退 **/
int  Kyohi_2_log = 0;		/** 拒否ログ数 900件/1800件 -> 9件/18件に縮退 **/
bool reset = false;		/** リセットフラグ **/

/*********************************************************************
 * 通信端末
 *********************************************************************/
proctype recv_device()
{
	recv_unit = TAIKI;		/** 受信装置の初期化 **/
	
	do
	::recv_unit == TAIKI;
		assert(Chaku_log < 100);
/*		assert(Kyohi_1_log < 30); */
/*		assert(Kyohi_2_log < 18); */
		if
		::ch_ope ? a_hatsu -> recv_unit = HATSU;
		::ch_com ? b_hatsu -> recv_unit = CHAKU;
			if
			::CHAKU_ST == SAVE ->
				if
				::Chaku_log == 49 -> CHAKU_ST = CLEAR;
					if
					::reset == false -> reset = !(reset);
					::else->skip;
					fi;
				::else->skip;
				fi;
			::else->skip;
			fi;
			if
			::Chaku_log < 100 -> Chaku_log++
			::else->skip;
			fi;
		fi;
	::recv_unit == HATSU;
		assert(Chaku_log < 100);
/*		assert(Kyohi_1_log < 30); */
/*		assert(Kyohi_2_log < 18); */
		if
		::ch_ope ? a_chuushi -> recv_unit = TAIKI;
		::ch_com ? b_outou -> recv_unit = TSUUWA; mtx = 1;
		::ch_com ? b_kyohi -> recv_unit = TAIKI;
			if
			::KYOHI_2_ST == SAVE ->
				if
				::Kyohi_2_log == 8 -> KYOHI_2_ST = CLEAR
					if
					::reset == false -> reset = !(reset)
					::else->skip;
					fi;
				::else->skip;
				fi;
			::else->skip;
			fi;
			if
			::Kyohi_2_log < 18 -> Kyohi_2_log++
			::else->skip;
			fi;
		fi;
	::recv_unit == CHAKU;
		assert(Chaku_log < 100);
/*		assert(Kyohi_1_log < 30); */
/*		assert(Kyohi_2_log < 18); */
		if
		::ch_ope ? a_outou -> TSUUWA;
			if
			::mtx == 0 -> mtx = 1;
			::mtx == 1 -> mtx = 2;
			::else->skip;
			fi;
		::ch_ope ? a_kyohi ->
			if
			::mtx == 0 -> recv_unit = TAIKI;
			::mtx == 1 -> recv_unit = TSUUWA;
			::else->skip;
			fi;
			if
			::KYOHI_1_ST == SAVE ->
				if
				::Kyohi_1_log == 14 -> KYOHI_1_ST = CLEAR
					if
					::reset == false -> reset = !(reset);
					::else->skip;
					fi;
				::else->skip;
				fi;
			::else->skip;
			fi;
			if
			::Kyohi_1_log < 30 -> Kyohi_1_log++
			::else->skip;
			fi;
		::ch_ope ? a_shuuryou ->
			if
			::mtx == 1 -> mtx = 0;
			::mtx == 2 -> mtx = 1;
			::else->skip;
			fi;
		::ch_com ? b_chuushi -> 
			if
			::mtx == 0 -> recv_unit = TAIKI;
			::mtx == 1 -> recv_unit = TSUUWA;
			::else->skip;
			fi;
		::ch_com ? b_shuuryou ->
			if
			::mtx == 1 -> mtx = 0;
			::mtx == 2 -> mtx = 1;
			::else->skip;
			fi;
		fi;
	::recv_unit == TSUUWA;
		assert(Chaku_log < 100);
/*		assert(Kyohi_1_log < 30); */
/*		assert(Kyohi_2_log < 18); */
		if
		::ch_ope ? a_shuuryou ->
			if
			::mtx == 1 -> recv_unit = TAIKI;
			::else->skip;
			fi;
			if
			::mtx == 1 -> mtx = 0;
			::mtx == 2 -> mtx = 1;
			::else->skip;
			fi;
		::ch_com ? b_hatsu ->
			if
			::mtx == 1 -> recv_unit = CHAKU;
			::else->skip;
			fi;
			if
			::mtx == 1 ->
				if
				::CHAKU_ST == SAVE ->
					if
					::Chaku_log == 49 -> CHAKU_ST = CLEAR;
						if
						::reset == false -> reset = !(reset);
						::else->skip;
						fi;
					::else->skip;
					fi;
				::else->skip;
				fi;
				if
				::Chaku_log < 100 -> Chaku_log++
				::else->skip;
				fi;
			::else->skip;
			fi;
		::ch_com ? b_shuuryou ->
			 if
			 ::mtx == 1 -> recv_unit = TAIKI;
			 ::else->skip;
			 fi;
			 if
			 ::mtx == 1 -> mtx = 0;
			 ::mtx == 2 -> mtx = 1;
			 ::else->skip;
			 fi;
		fi;
	od;
}

/*********************************************************************
 * リセット装置
 *********************************************************************/
proctype reset_device()
{
	reset_unit = INIT;
	
	do
	::reset_unit == INIT -> reset_unit = WAIT;
	::reset_unit == WAIT ->
		if
		::CHAKU_ST == CLEAR ->
			CHAKU_ST = SAVE;
			/** Backup **/
			Chaku_log = 0;
			reset = false;
		::else->skip;
		fi;
		if
		::KYOHI_1_ST == CLEAR ->
			KYOHI_1_ST = SAVE;
			/** Backup **/
			Kyohi_1_log = 0;
			reset = false;
		::else->skip;
		fi;
		if
		::KYOHI_2_ST == CLEAR ->
			KYOHI_2_ST = SAVE;
			/** Backup **/
			Kyohi_2_log = 0;
			reset = false;
		::else->skip;
		fi;
	od;
}

/*********************************************************************
 * ユーザーa　（テスト用外部環境）
 *	ランダムに通信端末(com_unit)を操作する
 *********************************************************************/
proctype user_a()
{
	do
	::ch_ope! a_hatsu;
	::ch_ope! a_outou;
	::ch_ope! a_chuushi;
	::ch_ope! a_kyohi;
	::ch_ope! a_shuuryou;
	od;
}

/*********************************************************************
 * 他通信端末b　（テスト用外部環境）
 *	テスト対象のcom_unitに操作メッセージをランダムに送信する
 *	（ランダムに通信端末(com_unit_b)を操作している状態をモデル化）
 *********************************************************************/
proctype com_unit_b()
{
	do
	::ch_com! b_hatsu;
	::ch_com! b_outou;
	::ch_com! b_chuushi;
	::ch_com! b_kyohi;
	::ch_com! b_shuuryou;
	od;
}

/*********************************************************************
 * 実行
 *********************************************************************/
init {
	run recv_device();
	run reset_device();
	run user_a();
	run com_unit_b();
	run com_unit_b();
}
