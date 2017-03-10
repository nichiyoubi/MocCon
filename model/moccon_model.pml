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
byte Chaku_log = 0;		/** ���M���� 5000��/10000�� -> 5��/10���ɏk�� **/
byte Kyohi_1_log = 0;		/** ���ۃ��O�� 1500��/3000�� -> 1��/3���ɏk�� **/
byte Kyohi_2_log = 0;		/** ���ۃ��O�� 900��/1800�� -> 1��/2���ɏk�� **/
bool reset = false;		/** ���Z�b�g�t���O **/

#define CHAKU_MAX		10	/** 10000����10���ɏk�� **/
#define CHAKU_THREASHOLD	5	/** 5000����5���ɏk�� **/
#define KYOHI_1_MAX		3	/** 3000����3���ɏk�� **/
#define KYOHI_1_THREASHOLD	1	/** 1500����1���ɏk�� **/
#define KYOHI_2_MAX		2	/** 1800����2���ɏk�� **/
#define KYOHI_2_THREASHOLD	1	/** 900����1���ɏk�� **/

inline mtx_increment() {
	if
	::mtx == 0 -> mtx = 1;
	::mtx == 1 -> mtx = 2;
	::else->skip;
	fi;
}

inline mtx_decrement() {
	if
	::mtx == 1 -> mtx = 0;
	::mtx == 2 -> mtx = 1;
	::else->skip;
	fi;
}

inline reset_flag_set() {
	if
	::reset == false -> reset = !(reset);
	::else->skip;
	fi;
}

inline log_check(LOG, LOG_THREASHOLD, LOG_ST) {
	if
	::LOG_ST == SAVE ->
		if
		::LOG == LOG_THREASHOLD -> LOG_ST = CLEAR;
			reset_flag_set();
		::else->skip;
		fi;
	::else->skip;
	fi;
}

inline log_write(LOG, LOG_MAX) {
	if
	::LOG < LOG_MAX -> LOG++
	::else->skip;
	fi;
}

inline assert_log() {
	assert(Chaku_log < CHAKU_MAX);
/*	assert(Kyohi_1_log < KYOHI_1_MAX); */
/*	assert(Kyohi_2_log < KYOHI_2_MAX); */
}


/*********************************************************************
 * �ʐM�[��
 *********************************************************************/
proctype recv_device()
{
	recv_unit = TAIKI;		/** ��M���u�̏����� **/
	
	do
	::recv_unit == TAIKI;
progress_taiki:
		assert_log();
		if
		::ch_ope ? a_hatsu -> recv_unit = HATSU;
		::ch_com ? b_hatsu -> recv_unit = CHAKU;
			log_check(Chaku_log, CHAKU_THREASHOLD, CHAKU_ST);
			log_write(Chaku_log, CHAKU_MAX);
		fi;
	::recv_unit == HATSU;
progress_hatsu:
		assert_log();
		if
		::ch_ope ? a_chuushi -> recv_unit = TAIKI;
		::ch_com ? b_outou -> recv_unit = TSUUWA; mtx = 1;
		::ch_com ? b_kyohi -> recv_unit = TAIKI;
			log_check(Kyohi_2_log, KYOHI_2_THREASHOLD, KYOHI_2_ST);
			log_write(Kyohi_2_log, KYOHI_2_MAX);
		fi;
	::recv_unit == CHAKU;
progress_chaku:
		assert_log();
		if
		::ch_ope ? a_outou -> TSUUWA;
			mtx_increment();
		::ch_ope ? a_kyohi ->
			if
			::mtx == 0 -> recv_unit = TAIKI;
			::mtx == 1 -> recv_unit = TSUUWA;
			::else->skip;
			fi;
			log_check(Kyohi_1_log, KYOHI_1_THREASHOLD, KYOHI_1_ST);
			log_write(Kyohi_1_log, KYOHI_1_MAX);
		::ch_ope ? a_shuuryou ->
			mtx_decrement();
		::ch_com ? b_chuushi -> 
			if
			::mtx == 0 -> recv_unit = TAIKI;
			::mtx == 1 -> recv_unit = TSUUWA;
			::else->skip;
			fi;
		::ch_com ? b_shuuryou ->
			mtx_decrement();
		fi;
	::recv_unit == TSUUWA;
progress_tsuuwa:
		assert_log();
		if
		::ch_ope ? a_shuuryou ->
			if
			::mtx == 1 -> recv_unit = TAIKI;
			::else->skip;
			fi;
			mtx_decrement();
		::ch_com ? b_hatsu ->
			if
			::mtx == 1 -> recv_unit = CHAKU;
			::else->skip;
			fi;
			if
			::mtx == 1 ->
				log_check(Chaku_log, CHAKU_THREASHOLD, CHAKU_ST);
				log_write(Chaku_log, CHAKU_MAX);
			::else->skip;
			fi;
		::ch_com ? b_shuuryou ->
			if
			::mtx == 1 -> recv_unit = TAIKI;
			::else->skip;
			fi;
			mtx_decrement();
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
progress_wait:
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
