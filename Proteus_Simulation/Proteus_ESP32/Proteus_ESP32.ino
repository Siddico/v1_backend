#include <ArduinoJson.h> 
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// ⚠️ هام جداً: تأكد من نسخ ملف sensor_data.h الخاص بك ووضعه في نفس المجلد مع هذا الكود
#include "sensor_data.h" 

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

const int LED_NORMAL = 17; // Green -> Normal (NSR)
const int LED_AF = 16;     // Red -> AF
const int LED_PAC = 18;    // Yellow -> PAC

void setup() {
  Serial.begin(115200);
  Wire.begin(22, 21); // SDA = 21, SCL = 22
  
  pinMode(LED_NORMAL, OUTPUT); pinMode(LED_PAC, OUTPUT); pinMode(LED_AF, OUTPUT);
  digitalWrite(LED_NORMAL, LOW); digitalWrite(LED_PAC, LOW); digitalWrite(LED_AF, LOW);
  
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
    Serial.println(F("SSD1306 allocation failed"));
  }
  
  display.clearDisplay(); display.setTextColor(SSD1306_WHITE); display.setTextSize(1);
  display.setCursor(10, 15); display.println("System Ready!"); display.display();
  delay(2000);
}

void loop() {
  display.clearDisplay(); display.setCursor(10, 15);
  display.println("Sending Data to PC..."); display.display();

  // 1. بناء رسالة الـ JSON من مصفوفة الإشارة
  String jsonPayload = "{\"signal\": [";
  for(int i = 0; i < 1250; i++) {
    jsonPayload += String(ppg_data[i], 5); 
    if(i < 1249) jsonPayload += ",";
  }
  jsonPayload += "]}";
  
  // 2. إرسال البيانات عبر السيريال إلى بايثون
  Serial.println(jsonPayload); 
  Serial.println("END_OF_DATA"); // علامة ليعرف بايثون أن الرسالة انتهت

  display.clearDisplay(); display.setCursor(10, 15);
  display.println("Waiting for AI API..."); display.display();

  // 3. انتظار الرد من الذكاء الاصطناعي (عن طريق بايثون)
  long startTime = millis();
  String response = "";
  bool responseReceived = false;

  while(millis() - startTime < 15000) { // انتظار لمدة 15 ثانية كحد أقصى
    if(Serial.available()) {
      response = Serial.readStringUntil('\n'); // قراءة النتيجة القادمة
      responseReceived = true;
      break;
    }
  }

  // 4. تحليل النتيجة وعرضها
  if(responseReceived) {
    StaticJsonDocument<300> doc;
    DeserializationError error = deserializeJson(doc, response);

    if (!error) {
      String prediction = doc["prediction"];
      float confidence = doc["confidence"];  
      int riskScore = doc["risk_score"];     
      
      digitalWrite(LED_NORMAL, LOW); digitalWrite(LED_AF, LOW); digitalWrite(LED_PAC, LOW);
      
      if (prediction == "NSR" || prediction == "Normal") digitalWrite(LED_NORMAL, HIGH);
      else if (prediction == "AF") digitalWrite(LED_AF, HIGH); 
      else if (prediction == "PAC") digitalWrite(LED_PAC, HIGH);

      display.clearDisplay(); display.setTextSize(1); display.setCursor(0, 0);
      display.println("--- AI PREDICTION ---");
      display.setTextSize(2); display.setCursor(0, 18);
      display.print("State: "); display.println(prediction);
      display.setTextSize(1); display.setCursor(0, 42);
      display.print("Conf: "); display.print(confidence * 100, 1); display.println("%");
      display.setCursor(0, 52); display.print("Risk: "); display.println(riskScore);
      display.display(); 
    } else {
      display.clearDisplay(); display.setCursor(0, 0);
      display.println("JSON Parse Error"); display.display();
    }
  } else {
    display.clearDisplay(); display.setCursor(0, 0);
    display.println("Timeout: No Response"); display.display();
  }

  delay(10000); // انتظر 10 ثواني قبل إعادة إرسال الإشارة مرة أخرى
}
