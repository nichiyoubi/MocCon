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

chan ch_ope = [0] of { mtype };	/* ���[�U�[����p�`���l�� */
chan ch_com = [0] of { mtype };	/* ���ʐM�[���Ƃ̒ʐM�p�`���l�� */

mtype recv_unit;     /* ��M���u�̏�� */
mtype reset_unit;    /* ���Z�b�g���u�̏�� */

byte mtx = 0;			/** �����ڑ��� (0, 1, 2) **/
byte CHAKU_ST = CLEAR;		/** ���M���� (CLEAR/SAVE) **/
byte KYOHI_1_ST = CLEAR;	/** �����ۗ��� (CLEAR/SAVE) **/
byte KYOHI_2_ST = CLEAR;	/** �����ۗ��� (CLEAR/SAVE) **/
int  Chaku_log = 0;		/** ���M���� 5000��/10000�� -> 50��/100���ɏk�� **/
int  Kyohi_1_log = 0;		/** ���ۃ��O�� 1500��/3000�� -> 15��/30���ɏk�� **/
int  Kyohi_2_log = 0;		/** ���ۃ��O�� 900��/1800�� -> 9��/18���ɏk�� **/
bool reset = false;		/** ���Z�b�g�t���O **/

/*********************************************************************
 * �ʐM�[��
 *********************************************************************/
proctype recv_device()
{
	recv_unit = TAIKI;		/** ��M���u�̏����� **/
	
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
 * ���Z�b�g���u
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
 * ���[�U�[a�@�i�e�X�g�p�O�����j
 *	�����_���ɒʐM�[��(com_unit)�𑀍삷��
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
 * ���ʐM�[��b�@�i�e�X�g�p�O�����j
 *	�e�X�g�Ώۂ�com_unit�ɑ��상�b�Z�[�W�������_���ɑ��M����
 *	�i�����_���ɒʐM�[��(com_unit_b)�𑀍삵�Ă����Ԃ����f�����j
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
 * ���s
 *********************************************************************/
init {
	run recv_device();
	run reset_device();
	run user_a();
	run com_unit_b();
	run com_unit_b();
}
