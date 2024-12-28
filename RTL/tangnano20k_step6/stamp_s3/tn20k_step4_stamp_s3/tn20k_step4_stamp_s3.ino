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
#include "romimage_hello_world.h"
#include "romimage_stepper.h"
#include "romimage_super_cobra.h"

#define PIN_BUTTON	0

#define PIN_LED		21
#define NUM_LEDS	1
CRGB leds[NUM_LEDS];

#define HSPI_MISO	13
#define HSPI_MOSI	11
#define HSPI_SCLK	12
#define HSPI_SS		10
SPISettings spi_settings = SPISettings( 30000000, MSBFIRST, SPI_MODE0 );
SPIClass *hspi = NULL;

int state = 0;

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
void setup() {
	Serial.begin( 115200 );
	Serial.println( "Start TN20K Step4" );

	pinMode( PIN_BUTTON, INPUT );

	hspi = new SPIClass(HSPI);
	hspi->begin( HSPI_SCLK, HSPI_MISO, HSPI_MOSI, HSPI_SS );
	pinMode( hspi->pinSS(), OUTPUT );

	FastLED.addLeds< WS2812, PIN_LED, GRB >( leds, NUM_LEDS );
	leds[0] = CRGB::Red;
	FastLED.show();
}

// --------------------------------------------------------------------
void loop() {
	int i;
	byte d;

	delay(15);

	switch( state ) {
	case 0:
		if( send_command( 0x00 ) == 0xA5 ) {
			Serial.println( "Connected FPGA MSX." );
			state++;
		}
		break;
	case 1:
		//	キーマトリクス初期化コマンド送信
		Serial.println( "Initialize key matrix" );
		for( i = 0; i < 16; i++ ) {
			send_key_matrix( i, 0xFF );
		}
		state++;
		Serial.println( "Wait key matrix" );
		break;
	case 2:
		//	SDRAM ready を待つ
		d = get_status() & 1;
		if( d == 0x00 ) {
			Serial.println( "SDRAM Initialize completed." );
			state++;
		}
		break;
	case 3:
		//	Send ROM images
		Serial.println( "Send MAIN-ROM 0" );
		send_rom_image( rom_main_00, sizeof(rom_main_00) );
		Serial.println( "Send MAIN-ROM 1" );
		send_rom_image( rom_main_01, sizeof(rom_main_01) );
		Serial.println( "Send BASIC'N" );
		send_rom_image( rom_basicn_00, sizeof(rom_basicn_00) );
		Serial.println( "hello world" );
		send_rom_image( rom_hello_world_00, sizeof(rom_hello_world_00) );
//		Serial.println( "Super Cobra" );
//		send_rom_image( rom_super_cobra_00, sizeof(rom_super_cobra_00) );
//		Serial.println( "Stepper" );
//		send_rom_image( rom_stepper_00, sizeof(rom_stepper_00) );
//		Serial.println( "RabbitAdventure 0" );
//		send_rom_image( rom_rabbit_adventure_00, sizeof(rom_rabbit_adventure_00) );
//		Serial.println( "RabbitAdventure 1" );
//		send_rom_image( rom_rabbit_adventure_01, sizeof(rom_rabbit_adventure_01) );

		Serial.println( "Fill 0" );
		send_zero_fill( 0x100 );
		send_zero_fill( 0x101 );
		send_zero_fill( 0x102 );
		send_zero_fill( 0x103 );
		state++;
		break;
	case 4:
		Serial.println( "Start FPGA MSX." );
		start_cpu();
		state++;
		break;
	default:
		delay( 10 );
		break;
	}
}
