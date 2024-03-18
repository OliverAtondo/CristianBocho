#include <ArduinoJson.h>
#include <NimBLEDevice.h>

#define LED 2
bool on = false;
bool off = false;

class MyServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
        Serial.println("Client connected");
        NimBLEDevice::stopAdvertising();
    };

    void onDisconnect(NimBLEServer* pServer) {
        Serial.println("Client disconnected");
        NimBLEDevice::startAdvertising();
    }
};

class MyCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) override {
        std::string value = pCharacteristic->getValue();
        if (value == "1") {
            on = true;
            off = false;
        } else if (value == "0") {
            on = false;
            off = true;
        }
    }
};


void setup() {
  Serial.begin(115200);
  Serial.println("Starting NimBLE Server");

  NimBLEDevice::init("VochitoBluetooth");
  NimBLEDevice::setPower(ESP_PWR_LVL_P9);

  NimBLEServer *pServer = NimBLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  NimBLEService *pService = pServer->createService("FDC7");

  NimBLECharacteristic* pCharacteristic = pService->createCharacteristic(
                                          "FD58",
                                          NIMBLE_PROPERTY::WRITE |
                                          NIMBLE_PROPERTY::READ
                                        );

  pCharacteristic->setCallbacks(new MyCallbacks());
  
  pService->start();

  NimBLEAdvertising *pAdvertising = NimBLEDevice::getAdvertising();
  pAdvertising->addServiceUUID("FDC7");
  pAdvertising->start();

  pinMode(LED,OUTPUT);
}

void loop() {
  if (on) {
    digitalWrite(LED, HIGH);
  }

  if (off) {
    digitalWrite(LED, LOW);
  }

  on = false;
  off = false;

  delay(1000);
}

