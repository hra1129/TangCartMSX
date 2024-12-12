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
SPISettings spi_settings = SPISettings( 8000000, MSBFIRST, SPI_MODE0 );
SPIClass *hspi = NULL;

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

    delay(15);

    if( !digitalRead( PIN_BUTTON ) ) {
        delay(5);
        if( !digitalRead( PIN_BUTTON ) ) {
            Serial.print( "Send command : " );
            if( send_command( 0x12 ) == 0xA5 ) {
                Serial.println( "Success." );
            }
            else {
                Serial.println( "Failed." );
            }
            while( !digitalRead(PIN_BUTTON) );
        }
    }
}
