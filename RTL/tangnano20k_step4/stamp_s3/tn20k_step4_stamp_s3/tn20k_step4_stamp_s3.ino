// --------------------------------------------------------------------
//  M5stampS3 sketch on TN20K step4
// ====================================================================
//  2024/12/12  t.hara (HRA!)
// --------------------------------------------------------------------

#include <Arduino.h>
#include <FastLED.h>
#include <SPI.h>

#define PIN_BUTTON  0

#define PIN_LED     21
#define NUM_LEDS    1
CRGB leds[NUM_LEDS];

#define HSPI_MISO   13
#define HSPI_MOSI   11
#define HSPI_SCLK   12
#define HSPI_SS     10
SPISettings spi_settings = SPISettings( 1000000, MSBFIRST, SPI_MODE0 );
SPIClass *hspi = NULL;

int state = 0;

// --------------------------------------------------------------------
byte send_command( byte data ) {
    hspi->beginTransaction( spi_settings );
    digitalWrite( hspi->pinSS(), LOW );  //pull SS slow to prep other end for transfer
    data = hspi->transfer( data );
    digitalWrite( hspi->pinSS(), HIGH );  //pull ss high to signify end of data transfer
    hspi->endTransaction();
    return data;
}

// --------------------------------------------------------------------
byte send_key_matrix( int y, byte data ) {
    hspi->beginTransaction( spi_settings );
    digitalWrite( hspi->pinSS(), LOW );  //pull SS slow to prep other end for transfer
    hspi->transfer( 0x03 );
    hspi->transfer( y );
    data = hspi->transfer( data );
    digitalWrite( hspi->pinSS(), HIGH );  //pull ss high to signify end of data transfer
    hspi->endTransaction();
    return data;
}

// --------------------------------------------------------------------
byte get_status( void ) {
    byte data;

    hspi->beginTransaction( spi_settings );
    digitalWrite( hspi->pinSS(), LOW );  //pull SS slow to prep other end for transfer
    hspi->transfer( 0x05 );
    data = hspi->transfer( 0x00 );
    digitalWrite( hspi->pinSS(), HIGH );  //pull ss high to signify end of data transfer
    hspi->endTransaction();
    return data;
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
        if( !digitalRead( PIN_BUTTON ) ) {
            delay(5);
            if( !digitalRead( PIN_BUTTON ) ) {
                Serial.print( "Send command : " );
                if( send_command( 0x00 ) == 0xA5 ) {
                    Serial.println( "Success." );
                    state = 1;
                }
                else {
                    Serial.println( "Failed." );
                }
                while( !digitalRead(PIN_BUTTON) );
            }
        }
        break;
    case 1:
        //  リセット解除コマンド送信
        Serial.println( "Send RESET off" );
        send_command( 0x02 );
        delay(5);
        //  キーマトリクス初期化コマンド送信
        Serial.println( "Initialize key matrix" );
        for( i = 0; i < 16; i++ ) {
            send_key_matrix( i, 0xFF );
        }
        d = get_status();
        if( d == 0x00 ) {
            Serial.println( "Status OK." );
        }
        else {
            Serial.printf( "Status error %02X\r\n", d );
        }
        state = 0;
        break;
    }
}
