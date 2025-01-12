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
#include "romimage_rabbit_adventure_demo.h"
#include "romimage_hello_world.h"
#include "romimage_stepper.h"
#include "romimage_super_cobra.h"
#include "romimage_kings_valley.h"
#include "romimage_dragon_quest2.h"
#include "romimage_gall_force.h"
#include "romimage_megarom_asc8.h"
#include "romimage_gradius.h"
#include "romimage_gradius2.h"

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
SPISettings spi_settings = SPISettings( 30000000, MSBFIRST, SPI_MODE0 );
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

// --------------------------------------------------------------------
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
void send_zero_fill( int bank_id ) {
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
		hspi->transfer( 0x00 );
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

// --------------------------------------------------------------------
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
	delayMicroseconds(10);
	GPIO.out_w1ts = GPIO.out_w1ts | row_tbl[ row ];
	delayMicroseconds(40);
}

// --------------------------------------------------------------------
unsigned char get_keyboard_col( void ) {
	unsigned char d;

	d = (unsigned char)(GPIO.in & 0x000000FF);
	return d;
}

//static int count = 0;

// --------------------------------------------------------------------
void update_key_matrix( void ) {
	int i;
	unsigned char prev;

	for( i = 0; i < 11; i++ ) {
		set_keyboard_row( i );
		prev = keymatrix[ i ];
		keymatrix[ i ] = get_keyboard_col();

//    count++;
//		if( i == 0 && count > 2000 ) {
//			keymatrix[ i ] = keymatrix[ i ] ^ 2;		//	★SuperCobra用 1連打
//		}
//    if( count == 3500 ) {
//      count = 0;
//    }

		if( keymatrix[ i ] != prev ) {
			send_key_matrix( i, keymatrix[ i ] );
			Serial.printf( "keymatrix[%d] = %02X;\r\n", i, keymatrix[i] );
		}
	}
}

// --------------------------------------------------------------------
void state4_main_loop( void ) {
	int reset_sw;

	update_key_matrix();

	reset_sw = digitalRead( PIN_RESET_SW );
	if( reset_sw != last_reset ) {
		last_reset = reset_sw;
		if( reset_sw ) {
			send_reset_on();
		}
		else {
			send_reset_off();
		}
	}

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
//	Serial.println( "hello world 0" );
//	send_rom_image( rom_hello_world_00, sizeof(rom_hello_world_00) );
//	Serial.println( "hello world 1" );
//	send_rom_image( rom_hello_world_01, sizeof(rom_hello_world_01) );
//	set_megarom_mode( 1, MEGAROM_LINEAR );

//	Serial.println( "Super Cobra" );
//	send_rom_image( rom_super_cobra_00, sizeof(rom_super_cobra_00) );
//	set_megarom_mode( 1, MEGAROM_ASC16 );

//	Serial.println( "kings_valley" );
//	send_rom_image( rom_kings_valley_00, sizeof(rom_kings_valley_00) );
//	set_megarom_mode( 1, MEGAROM_ASC16 );

//	Serial.println( "Stepper" );
//	send_rom_image( rom_stepper_00, sizeof(rom_stepper_00) );
//	set_megarom_mode( 1, MEGAROM_ASC16 );

//	Serial.println( "RabbitAdventure 0" );
//	send_rom_image( rom_rabbit_adventure_00, sizeof(rom_rabbit_adventure_00) );
//	Serial.println( "RabbitAdventure 1" );
//	send_rom_image( rom_rabbit_adventure_01, sizeof(rom_rabbit_adventure_01) );
//	set_megarom_mode( 1, MEGAROM_LINEAR );

//	Serial.println( "RabbitAdventureDEMO 0" );
//	send_rom_image( rom_rabbit_adventure_demo_00, sizeof(rom_rabbit_adventure_demo_00) );
//	Serial.println( "RabbitAdventureDEMO 1" );
//	send_rom_image( rom_rabbit_adventure_demo_01, sizeof(rom_rabbit_adventure_demo_01) );
//	set_megarom_mode( 1, MEGAROM_LINEAR );

//	Serial.println( "dragon_quest2" );
//	send_rom_image( rom_dragon_quest2_00, sizeof(rom_dragon_quest2_00) );
//	send_rom_image( rom_dragon_quest2_01, sizeof(rom_dragon_quest2_01) );
//	send_rom_image( rom_dragon_quest2_02, sizeof(rom_dragon_quest2_02) );
//	send_rom_image( rom_dragon_quest2_03, sizeof(rom_dragon_quest2_03) );
//	send_rom_image( rom_dragon_quest2_04, sizeof(rom_dragon_quest2_04) );
//	send_rom_image( rom_dragon_quest2_05, sizeof(rom_dragon_quest2_05) );
//	send_rom_image( rom_dragon_quest2_06, sizeof(rom_dragon_quest2_06) );
//	send_rom_image( rom_dragon_quest2_07, sizeof(rom_dragon_quest2_07) );
//	send_rom_image( rom_dragon_quest2_08, sizeof(rom_dragon_quest2_08) );
//	send_rom_image( rom_dragon_quest2_09, sizeof(rom_dragon_quest2_09) );
//	send_rom_image( rom_dragon_quest2_0A, sizeof(rom_dragon_quest2_0A) );
//	send_rom_image( rom_dragon_quest2_0B, sizeof(rom_dragon_quest2_0B) );
//	send_rom_image( rom_dragon_quest2_0C, sizeof(rom_dragon_quest2_0C) );
//	send_rom_image( rom_dragon_quest2_0D, sizeof(rom_dragon_quest2_0D) );
//	send_rom_image( rom_dragon_quest2_0E, sizeof(rom_dragon_quest2_0E) );
//	send_rom_image( rom_dragon_quest2_0F, sizeof(rom_dragon_quest2_0F) );
//	set_megarom_mode( 1, MEGAROM_ASC8 );

//	Serial.println( "gall_force" );
//	send_rom_image( rom_gall_force_00, sizeof(rom_gall_force_00) );
//	send_rom_image( rom_gall_force_01, sizeof(rom_gall_force_01) );
//	send_rom_image( rom_gall_force_02, sizeof(rom_gall_force_02) );
//	send_rom_image( rom_gall_force_03, sizeof(rom_gall_force_03) );
//	send_rom_image( rom_gall_force_04, sizeof(rom_gall_force_04) );
//	send_rom_image( rom_gall_force_05, sizeof(rom_gall_force_05) );
//	send_rom_image( rom_gall_force_06, sizeof(rom_gall_force_06) );
//	send_rom_image( rom_gall_force_07, sizeof(rom_gall_force_07) );
//	set_megarom_mode( 1, MEGAROM_ASC16 );

//	Serial.println( "megarom_asc8" );
//	send_rom_image( rom_megarom_asc8_00, sizeof(rom_megarom_asc8_00) );
//	send_rom_image( rom_megarom_asc8_01, sizeof(rom_megarom_asc8_01) );
//	send_rom_image( rom_megarom_asc8_02, sizeof(rom_megarom_asc8_02) );
//	send_rom_image( rom_megarom_asc8_03, sizeof(rom_megarom_asc8_03) );
//	set_megarom_mode( 1, MEGAROM_ASC8 );

//	Serial.println( "gradius" );
//	send_rom_image( rom_gradius_00, sizeof(rom_gradius_00) );
//	send_rom_image( rom_gradius_01, sizeof(rom_gradius_01) );
//	send_rom_image( rom_gradius_02, sizeof(rom_gradius_02) );
//	send_rom_image( rom_gradius_03, sizeof(rom_gradius_03) );
//	send_rom_image( rom_gradius_04, sizeof(rom_gradius_04) );
//	send_rom_image( rom_gradius_05, sizeof(rom_gradius_05) );
//	send_rom_image( rom_gradius_06, sizeof(rom_gradius_06) );
//	send_rom_image( rom_gradius_07, sizeof(rom_gradius_07) );
//	set_megarom_mode( 1, MEGAROM_KONVRC );

	Serial.println( "gradius2" );
	send_rom_image( rom_gradius2_00, sizeof(rom_gradius2_00) );
	send_rom_image( rom_gradius2_01, sizeof(rom_gradius2_01) );
	send_rom_image( rom_gradius2_02, sizeof(rom_gradius2_02) );
	send_rom_image( rom_gradius2_03, sizeof(rom_gradius2_03) );
	send_rom_image( rom_gradius2_04, sizeof(rom_gradius2_04) );
	send_rom_image( rom_gradius2_05, sizeof(rom_gradius2_05) );
	send_rom_image( rom_gradius2_06, sizeof(rom_gradius2_06) );
	send_rom_image( rom_gradius2_07, sizeof(rom_gradius2_07) );
	set_megarom_mode( 1, MEGAROM_KONSCC );

	Serial.println( "Start FPGA MSX." );
	start_cpu();
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
