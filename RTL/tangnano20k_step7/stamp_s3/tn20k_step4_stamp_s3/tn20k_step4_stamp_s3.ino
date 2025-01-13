// --------------------------------------------------------------------
//	M5stampS3 sketch on TN20K step4
// ====================================================================
//	2024/12/12	t.hara (HRA!)
// --------------------------------------------------------------------

#include <Arduino.h>
#include <FastLED.h>
#include <SPI.h>
#include "romimage_main.h"
#include "romimage_basicn.h"
#include "romimage_rabbit_adventure.h"
//#include "romimage_hello_world.h"
#include "romimage_stepper.h"
#include "romimage_super_cobra.h"
#include "romimage_kings_valley.h"
#include "romimage_dragon_quest2.h"
#include "romimage_gall_force.h"
#include "romimage_gradius.h"
//#include "romimage_gradius2.h"
#include "romimage_kanji_driver.h"
#include "romimage_kanji_font.h"
//#include "romimage_tiny_slot_checker.h"
//#include "romimage_msx_write.h"
#include "romimage_stevedore.h"

#define PIN_BUTTON		0
#define PIN_Y0			8
#define PIN_Y1			9
#define PIN_Y2			14
#define PIN_Y3			15
#define PIN_X0			0
#define PIN_X1			1
#define PIN_X2			2
#define PIN_X3			3
#define PIN_X4			4
#define PIN_X5			5
#define PIN_X6			6
#define PIN_X7			7
#define PIN_KANA_LED	42
#define PIN_CAPS_LED	46
#define PIN_RESET_SW	43

#define PIN_LED			21
#define NUM_LEDS		1
CRGB leds[NUM_LEDS];

#define HSPI_MISO		13
#define HSPI_MOSI		11
#define HSPI_SCLK		12
#define HSPI_SS			10
SPISettings spi_settings = SPISettings( 36000000, MSBFIRST, SPI_MODE0 );
SPIClass *hspi = NULL;

static void (*p_function)( void );

static unsigned char keymatrix[16];
static int last_reset = 0;

#define MEGAROM_ASC16	0
#define MEGAROM_ASC8	1
#define MEGAROM_KONSCC	2
#define MEGAROM_KONSCCI	3
#define MEGAROM_LINEAR	4
#define MEGAROM_KONVRC	6
#define MEGAROM_MSXWRITE	7

// ====================================================================
//	SPI Commands
// ====================================================================
byte send_command( byte data ) {
	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	data = hspi->transfer( data );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
	return data;
}

// --------------------------------------------------------------------
byte send_key_matrix( int y, byte data ) {
	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x03 );
	hspi->transfer( y );
	data = hspi->transfer( data );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
	return data;
}

// --------------------------------------------------------------------
byte get_status( void ) {
	byte data;

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x05 );
	data = hspi->transfer( 0x00 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
	return data;
}

// --------------------------------------------------------------------
void send_rom_image( const byte *p_rom_image, int rom_size ) {
	int i, bank;

	bank = 0;
	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x07 );
	hspi->transfer( bank );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	delay(10);
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	for( i = 0; i < rom_size; i++ ) {
		hspi->transfer( p_rom_image[i] );
	}
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void send_FF_fill( int bank_id ) {
	int i, bank;

	bank = bank_id >> 8;
	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x07 );
	hspi->transfer( bank );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	delay(10);
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x04 );
	hspi->transfer( bank_id & 255 );
	for( i = 0; i < 16384; i++ ) {
		hspi->transfer( 0xFF );
	}
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void start_cpu( void ) {

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x06 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	delay( 5 );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x02 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void stop_cpu( void ) {

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x01 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	delay( 5 );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x0A );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void set_megarom_mode( int slot_no, int mode ) {

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	if( slot_no == 1 ) {
		hspi->transfer( 0x08 );
	}
	else {
		hspi->transfer( 0x09 );
	}
	hspi->transfer( mode );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void send_reset_on( void ) {

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x01 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// --------------------------------------------------------------------
void send_reset_off( void ) {

	hspi->beginTransaction( spi_settings );
	digitalWrite( hspi->pinSS(), LOW );	 //pull SS slow to prep other end for transfer
	hspi->transfer( 0x02 );
	digitalWrite( hspi->pinSS(), HIGH );  //pull SS high to signify end of data transfer
	hspi->endTransaction();
}

// ====================================================================
//	(1) Rabbit Adventure (default)
//	(2) King's valley
//	(3) Stepper
//	(4) DragonQuest2
//	(5) Gradius
//	(6) Gradius2
//	(7) MSX-Write
//	(0) MSX-BASIC with BASIC'N and KanjiDriver
// ====================================================================
void set_blank( void ) {
	send_FF_fill( 0x80 );
	send_FF_fill( 0x81 );
	send_FF_fill( 0x82 );
	send_FF_fill( 0x83 );
	set_megarom_mode( 1, MEGAROM_LINEAR );
}

// --------------------------------------------------------------------
//void set_test_rom( void ) {
//	Serial.println( "hello world" );
//	set_blank();
//	send_rom_image( rom_hello_world_00, sizeof(rom_hello_world_00) );
//	send_rom_image( rom_hello_world_01, sizeof(rom_hello_world_01) );
//	set_megarom_mode( 1, MEGAROM_LINEAR );
//}

// --------------------------------------------------------------------
//void set_tiny_slot_checker( void ) {
//	Serial.println( "tiny slot checker" );
//	set_blank();
//	send_rom_image( rom_tiny_slot_checker_00, sizeof(rom_tiny_slot_checker_00) );
//	set_megarom_mode( 1, MEGAROM_LINEAR );
//}

// --------------------------------------------------------------------
void set_super_cobra( void ) {
	Serial.println( "Super Cobra" );
	set_blank();
	send_rom_image( rom_super_cobra_00, sizeof(rom_super_cobra_00) );
}

// --------------------------------------------------------------------
void set_stepper( void ) {
	Serial.println( "Stepper" );
	set_blank();
	send_rom_image( rom_stepper_00, sizeof(rom_stepper_00) );
}

// --------------------------------------------------------------------
void set_kings_valley( void ) {
	Serial.println( "kings_valley" );
	set_blank();
	send_rom_image( rom_kings_valley_00, sizeof(rom_kings_valley_00) );
}

// --------------------------------------------------------------------
void set_rabbit_adventure( void ) {
	Serial.println( "RabbitAdventure" );
	set_blank();
	send_rom_image( rom_rabbit_adventure_00, sizeof(rom_rabbit_adventure_00) );
	send_rom_image( rom_rabbit_adventure_01, sizeof(rom_rabbit_adventure_01) );
}

// --------------------------------------------------------------------
void set_dragon_quest2( void ) {
	Serial.println( "dragon_quest2" );
	send_rom_image( rom_dragon_quest2_00, sizeof(rom_dragon_quest2_00) );
	send_rom_image( rom_dragon_quest2_01, sizeof(rom_dragon_quest2_01) );
	send_rom_image( rom_dragon_quest2_02, sizeof(rom_dragon_quest2_02) );
	send_rom_image( rom_dragon_quest2_03, sizeof(rom_dragon_quest2_03) );
	send_rom_image( rom_dragon_quest2_04, sizeof(rom_dragon_quest2_04) );
	send_rom_image( rom_dragon_quest2_05, sizeof(rom_dragon_quest2_05) );
	send_rom_image( rom_dragon_quest2_06, sizeof(rom_dragon_quest2_06) );
	send_rom_image( rom_dragon_quest2_07, sizeof(rom_dragon_quest2_07) );
	send_rom_image( rom_dragon_quest2_08, sizeof(rom_dragon_quest2_08) );
	send_rom_image( rom_dragon_quest2_09, sizeof(rom_dragon_quest2_09) );
	send_rom_image( rom_dragon_quest2_0A, sizeof(rom_dragon_quest2_0A) );
	send_rom_image( rom_dragon_quest2_0B, sizeof(rom_dragon_quest2_0B) );
	send_rom_image( rom_dragon_quest2_0C, sizeof(rom_dragon_quest2_0C) );
	send_rom_image( rom_dragon_quest2_0D, sizeof(rom_dragon_quest2_0D) );
	send_rom_image( rom_dragon_quest2_0E, sizeof(rom_dragon_quest2_0E) );
	send_rom_image( rom_dragon_quest2_0F, sizeof(rom_dragon_quest2_0F) );
	set_megarom_mode( 1, MEGAROM_ASC8 );
}

// --------------------------------------------------------------------
void set_gall_force( void ) {
	Serial.println( "gall_force" );
	send_rom_image( rom_gall_force_00, sizeof(rom_gall_force_00) );
	send_rom_image( rom_gall_force_01, sizeof(rom_gall_force_01) );
	send_rom_image( rom_gall_force_02, sizeof(rom_gall_force_02) );
	send_rom_image( rom_gall_force_03, sizeof(rom_gall_force_03) );
	send_rom_image( rom_gall_force_04, sizeof(rom_gall_force_04) );
	send_rom_image( rom_gall_force_05, sizeof(rom_gall_force_05) );
	send_rom_image( rom_gall_force_06, sizeof(rom_gall_force_06) );
	send_rom_image( rom_gall_force_07, sizeof(rom_gall_force_07) );
	set_megarom_mode( 1, MEGAROM_ASC16 );
}

// --------------------------------------------------------------------
void set_gradius( void ) {
	Serial.println( "gradius" );
	send_rom_image( rom_gradius_00, sizeof(rom_gradius_00) );
	send_rom_image( rom_gradius_01, sizeof(rom_gradius_01) );
	send_rom_image( rom_gradius_02, sizeof(rom_gradius_02) );
	send_rom_image( rom_gradius_03, sizeof(rom_gradius_03) );
	send_rom_image( rom_gradius_04, sizeof(rom_gradius_04) );
	send_rom_image( rom_gradius_05, sizeof(rom_gradius_05) );
	send_rom_image( rom_gradius_06, sizeof(rom_gradius_06) );
	send_rom_image( rom_gradius_07, sizeof(rom_gradius_07) );
	set_megarom_mode( 1, MEGAROM_KONVRC );
}

// --------------------------------------------------------------------
//void set_gradius2( void ) {
//	Serial.println( "gradius2" );
//	send_rom_image( rom_gradius2_00, sizeof(rom_gradius2_00) );
//	send_rom_image( rom_gradius2_01, sizeof(rom_gradius2_01) );
//	send_rom_image( rom_gradius2_02, sizeof(rom_gradius2_02) );
//	send_rom_image( rom_gradius2_03, sizeof(rom_gradius2_03) );
//	send_rom_image( rom_gradius2_04, sizeof(rom_gradius2_04) );
//	send_rom_image( rom_gradius2_05, sizeof(rom_gradius2_05) );
//	send_rom_image( rom_gradius2_06, sizeof(rom_gradius2_06) );
//	send_rom_image( rom_gradius2_07, sizeof(rom_gradius2_07) );
//	set_megarom_mode( 1, MEGAROM_KONSCC );
//}

// --------------------------------------------------------------------
//void set_msxwrite( void ) {
//	Serial.println( "MSX-Write" );
//	send_rom_image( rom_msx_write_00, sizeof(rom_msx_write_00) );
//	send_rom_image( rom_msx_write_01, sizeof(rom_msx_write_01) );
//	send_rom_image( rom_msx_write_02, sizeof(rom_msx_write_02) );
//	send_rom_image( rom_msx_write_03, sizeof(rom_msx_write_03) );
//	send_rom_image( rom_msx_write_04, sizeof(rom_msx_write_04) );
//	send_rom_image( rom_msx_write_05, sizeof(rom_msx_write_05) );
//	send_rom_image( rom_msx_write_06, sizeof(rom_msx_write_06) );
//	send_rom_image( rom_msx_write_07, sizeof(rom_msx_write_07) );
//	send_rom_image( rom_msx_write_08, sizeof(rom_msx_write_08) );
//	send_rom_image( rom_msx_write_09, sizeof(rom_msx_write_09) );
//	send_rom_image( rom_msx_write_0A, sizeof(rom_msx_write_0A) );
//	send_rom_image( rom_msx_write_0B, sizeof(rom_msx_write_0B) );
//	send_rom_image( rom_msx_write_0C, sizeof(rom_msx_write_0C) );
//	send_rom_image( rom_msx_write_0D, sizeof(rom_msx_write_0D) );
//	send_rom_image( rom_msx_write_0E, sizeof(rom_msx_write_0E) );
//	send_rom_image( rom_msx_write_0F, sizeof(rom_msx_write_0F) );
//	send_rom_image( rom_msx_write_10, sizeof(rom_msx_write_10) );
//	send_rom_image( rom_msx_write_11, sizeof(rom_msx_write_11) );
//	send_rom_image( rom_msx_write_12, sizeof(rom_msx_write_12) );
//	send_rom_image( rom_msx_write_13, sizeof(rom_msx_write_13) );
//	send_rom_image( rom_msx_write_14, sizeof(rom_msx_write_14) );
//	send_rom_image( rom_msx_write_15, sizeof(rom_msx_write_15) );
//	send_rom_image( rom_msx_write_16, sizeof(rom_msx_write_16) );
//	send_rom_image( rom_msx_write_17, sizeof(rom_msx_write_17) );
//	send_rom_image( rom_msx_write_18, sizeof(rom_msx_write_18) );
//	send_rom_image( rom_msx_write_19, sizeof(rom_msx_write_19) );
//	send_rom_image( rom_msx_write_1A, sizeof(rom_msx_write_1A) );
//	send_rom_image( rom_msx_write_1B, sizeof(rom_msx_write_1B) );
//	send_rom_image( rom_msx_write_1C, sizeof(rom_msx_write_1C) );
//	send_rom_image( rom_msx_write_1D, sizeof(rom_msx_write_1D) );
//	send_rom_image( rom_msx_write_1E, sizeof(rom_msx_write_1E) );
//	send_rom_image( rom_msx_write_1F, sizeof(rom_msx_write_1F) );
//	set_megarom_mode( 1, MEGAROM_MSXWRITE );
//}

// --------------------------------------------------------------------
void set_stevedore( void ) {

	Serial.println( "stevedore" );
	set_blank();
	send_rom_image( rom_stevedore_00, sizeof(rom_stevedore_00) );
	send_rom_image( rom_stevedore_01, sizeof(rom_stevedore_01) );
	send_rom_image( rom_stevedore_02, sizeof(rom_stevedore_02) );
}

// ====================================================================
//	Keyboard driver
// ====================================================================
void set_keyboard_row( int row ) {
	static const uint32_t row_tbl[] = { 
		0x0000,
		0x0100,
		0x0200,
		0x0300,
		0x4000,
		0x4100,
		0x4200,
		0x4300,
		0x8000,
		0x8100,
		0x8200,
		0x8300,
		0xC000,
		0xC100,
		0xC200,
		0xC300,
	};
	GPIO.out_w1tc = GPIO.out_w1tc | 0xC300;
	delayMicroseconds(100);
	GPIO.out_w1ts = GPIO.out_w1ts | row_tbl[ row ];
	delayMicroseconds(100);
}

// --------------------------------------------------------------------
unsigned char get_keyboard_col( void ) {
	unsigned char d;

	d = (unsigned char)(GPIO.in & 0x000000FF);
	return d;
}

// --------------------------------------------------------------------
void update_key_matrix( void ) {
	int i;
	unsigned char prev;

	for( i = 0; i < 11; i++ ) {
		set_keyboard_row( i );
		prev = keymatrix[ i ];
		keymatrix[ i ] = get_keyboard_col();
		if( keymatrix[ i ] != prev ) {
			send_key_matrix( i, keymatrix[ i ] );
		}
	}
}

// --------------------------------------------------------------------
void send_cartridge( void ) {
	unsigned char x;

	//	キーボードの Y0 を取得する 
	set_keyboard_row( 0 );
	x = get_keyboard_col();
	Serial.printf( "Key check: %02X\r\n", x );
	if(      (x & (1 << 1)) == 0 ) {
		set_kings_valley();
	}
	else if( (x & (1 << 2)) == 0 ) {
		set_stepper();
	}
	else if( (x & (1 << 3)) == 0 ) {
		set_gall_force();
	}
	else if( (x & (1 << 4)) == 0 ) {
		set_dragon_quest2();
	}
	else if( (x & (1 << 5)) == 0 ) {
		set_gradius();
	}
	else if( (x & (1 << 6)) == 0 ) {
		set_stevedore();
	}
	else if( (x & (1 << 7)) == 0 ) {
		set_super_cobra();
	}
	else if( (x & (1 << 0)) == 0 ) {
		set_rabbit_adventure();
	}
	else {
		set_blank();
	}
}

// --------------------------------------------------------------------
void update_led( void ) {
	byte status;

	status = get_status();
	if( (status & (1 << 1)) == 0 ) {
		digitalWrite( PIN_CAPS_LED, 0 );
	}
	else {
		digitalWrite( PIN_CAPS_LED, 1 );
	}
	if( (status & (1 << 2)) == 0 ) {
		digitalWrite( PIN_KANA_LED, 0 );
	}
	else {
		digitalWrite( PIN_KANA_LED, 1 );
	}
}

// --------------------------------------------------------------------
void state4_main_loop( void ) {
	static int led_update_counter = 0;
	int reset_sw;

	update_key_matrix();

	reset_sw = digitalRead( PIN_RESET_SW );
	if( reset_sw != last_reset ) {
		last_reset = reset_sw;
		if( reset_sw ) {
			stop_cpu();
		}
		else {
			send_cartridge();
			start_cpu();
		}
	}

	if( led_update_counter == 0 ) {
		update_led();
		led_update_counter = 10;
	}
	led_update_counter--;
	
	delayMicroseconds(500);
}

// --------------------------------------------------------------------
void state3_send_rom_image( void ) {
	//	Send ROM images
	Serial.println( "Send MAIN-ROM 0" );
	send_rom_image( rom_main_00, sizeof(rom_main_00) );
	Serial.println( "Send MAIN-ROM 1" );
	send_rom_image( rom_main_01, sizeof(rom_main_01) );
	Serial.println( "Send BASIC'N" );
	send_rom_image( rom_basicn_00, sizeof(rom_basicn_00) );
	Serial.println( "Send KanjiDriver" );
	send_rom_image( rom_kanji_driver_00, sizeof(rom_kanji_driver_00) );
	send_rom_image( rom_kanji_driver_01, sizeof(rom_kanji_driver_01) );
	Serial.println( "Send KanjiFont" );
	send_rom_image( rom_kanji_font_00, sizeof(rom_kanji_font_00) );
	send_rom_image( rom_kanji_font_01, sizeof(rom_kanji_font_01) );
	send_rom_image( rom_kanji_font_02, sizeof(rom_kanji_font_02) );
	send_rom_image( rom_kanji_font_03, sizeof(rom_kanji_font_03) );
	send_rom_image( rom_kanji_font_04, sizeof(rom_kanji_font_04) );
	send_rom_image( rom_kanji_font_05, sizeof(rom_kanji_font_05) );
	send_rom_image( rom_kanji_font_06, sizeof(rom_kanji_font_06) );
	send_rom_image( rom_kanji_font_07, sizeof(rom_kanji_font_07) );
	send_rom_image( rom_kanji_font_08, sizeof(rom_kanji_font_08) );
	send_rom_image( rom_kanji_font_09, sizeof(rom_kanji_font_09) );
	send_rom_image( rom_kanji_font_0A, sizeof(rom_kanji_font_0A) );
	send_rom_image( rom_kanji_font_0B, sizeof(rom_kanji_font_0B) );
	send_rom_image( rom_kanji_font_0C, sizeof(rom_kanji_font_0C) );
	send_rom_image( rom_kanji_font_0D, sizeof(rom_kanji_font_0D) );
	send_rom_image( rom_kanji_font_0E, sizeof(rom_kanji_font_0E) );
	send_rom_image( rom_kanji_font_0F, sizeof(rom_kanji_font_0F) );

	send_cartridge();

	Serial.println( "Start FPGA MSX." );
	start_cpu();
	last_reset = digitalRead( PIN_RESET_SW );
	p_function = state4_main_loop;
}

// --------------------------------------------------------------------
void state2_wait_ready( void ) {
	byte d;

	//	SDRAM ready を待つ
	d = get_status() & 1;
	if( d == 0x00 ) {
		Serial.println( "SDRAM Initialize completed." );
		p_function = state3_send_rom_image;
	}
}

// --------------------------------------------------------------------
void state1_initialize_keymatrix( void ) {
	int i;

	//	キーマトリクス初期化コマンド送信
	Serial.println( "Initialize key matrix" );
	for( i = 0; i < 16; i++ ) {
		send_key_matrix( i, 0xFF );
	}
	Serial.println( "Wait key matrix" );
	p_function = state2_wait_ready;
}

// --------------------------------------------------------------------
void state0_connection( void ) {
	if( send_command( 0x00 ) == 0xA5 ) {
		Serial.println( "Connected FPGA MSX." );
		p_function = state1_initialize_keymatrix;
	}
}

// --------------------------------------------------------------------
void setup() {
	Serial.begin( 115200 );
	Serial.println( "Start TN20K Step4" );

	pinMode( PIN_BUTTON, INPUT );
	pinMode( PIN_Y0, OUTPUT );
	pinMode( PIN_Y1, OUTPUT );
	pinMode( PIN_Y2, OUTPUT );
	pinMode( PIN_Y3, OUTPUT );
	pinMode( PIN_X0, INPUT_PULLUP );
	pinMode( PIN_X1, INPUT_PULLUP );
	pinMode( PIN_X2, INPUT_PULLUP );
	pinMode( PIN_X3, INPUT_PULLUP );
	pinMode( PIN_X4, INPUT_PULLUP );
	pinMode( PIN_X5, INPUT_PULLUP );
	pinMode( PIN_X6, INPUT_PULLUP );
	pinMode( PIN_X7, INPUT_PULLUP );
	pinMode( PIN_KANA_LED, OUTPUT );
	pinMode( PIN_CAPS_LED, OUTPUT );
	pinMode( PIN_RESET_SW, INPUT );

	hspi = new SPIClass(HSPI);
	hspi->begin( HSPI_SCLK, HSPI_MISO, HSPI_MOSI, HSPI_SS );
	pinMode( hspi->pinSS(), OUTPUT );

	FastLED.addLeds< WS2812, PIN_LED, GRB >( leds, NUM_LEDS );
	leds[0] = CRGB::Red;
	FastLED.show();

	memset( keymatrix, 0xFF, sizeof(keymatrix) );
	p_function	= state0_connection;
}

// --------------------------------------------------------------------
void loop() {
	p_function();
}
