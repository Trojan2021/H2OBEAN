#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEClient.h>

BLEClient* pClient;
bool connected = false;

void setup() {
    Serial.begin(115200);

    BLEDevice::init("MyESP32");

    pClient = BLEDevice::createClient();

    // Replace with the MAC address of your Raspberry Pi's Bluetooth adapter
    BLEAddress serverAddress("XX:XX:XX:XX:XX:XX");
    
    pClient->connect(serverAddress);
}

void loop() {
    if (connected) {
        // Modify this part to send your data to the Raspberry Pi
        String dataToSend = "Hello, Raspberry Pi!";
        pClient->write((uint8_t*)dataToSend.c_str(), dataToSend.length());
        delay(1000);
    } else {
        if (pClient->isConnected()) {
            Serial.println("Connected to the server");
            connected = true;
        } else {
            Serial.println("Connection failed. Retrying...");
            delay(500);
        }
    }
}
