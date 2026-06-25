import serial
import requests
import json
import time

# ==============================================================
# إعدادات الاتصال (قم بتعديلها لتطابق إعداداتك)
# ==============================================================
# اسم البورت الخاص بالبايثون (يجب أن يكون البورت المرتبط بالبورت الخاص ببروتس عبر com0com)
# مثلاً: إذا كان بروتس متصل بـ COM1، اجعل هذا COM2
COM_PORT = 'COM2' 
BAUD_RATE = 115200

# رابط الـ API الخاص بالذكاء الاصطناعي
API_URL = "https://mohammedsiddiq07-strokepredict-ai.hf.space/predict"
# ==============================================================

try:
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print("==================================================")
    print(f"✅ Connected to {COM_PORT} successfully!")
    print("⏳ Waiting for PPG Data from Proteus ESP32...")
    print("==================================================")
except Exception as e:
    print(f"❌ Error opening port {COM_PORT}: {e}")
    print("\n⚠️ تنبيه هام:")
    print("يرجى التأكد من تشغيل برنامج com0com لإنشاء البورتات الوهمية (COM1 و COM2).")
    print("وتأكد أن برنامج Proteus يستخدم البورت الآخر.")
    exit()

while True:
    if ser.in_waiting > 0:
        print("\n📥 Receiving data from ESP32 in Proteus...")
        data_str = ""
        
        # قراءة الإشارة كاملة سطر بسطر حتى نصل للعلامة الدليلية
        while True:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line == "END_OF_DATA":
                    break
                if line:
                    data_str += line
            except UnicodeDecodeError:
                pass # تجاهل الأخطاء البسيطة في القراءة

        if data_str:
            print("✅ Data received fully! Sending to Hugging Face API...")
            try:
                # التأكد من صحة شكل الـ JSON
                payload = json.loads(data_str)
                headers = {'Content-Type': 'application/json'}
                
                # إرسال البيانات للـ API
                response = requests.post(API_URL, json=payload, headers=headers)
                
                if response.status_code == 200:
                    ai_result = response.text
                    print(f"🎉 Success! AI Prediction: {ai_result}")
                    
                    # إرسال النتيجة إلى بروتس مرة أخرى (مع إضافة سطر جديد ليعرف الأردوينو أن الرسالة انتهت)
                    ser.write((ai_result + '\n').encode('utf-8'))
                    print("📤 Sent result back to Proteus successfully.")
                else:
                    print(f"❌ API Error Code: {response.status_code}")
                    print(f"Response: {response.text}")
                    
            except json.JSONDecodeError as e:
                print(f"❌ JSON Parsing Error: {e}")
                print("The data received from Proteus is not a valid JSON format.")
            except requests.exceptions.RequestException as e:
                print(f"❌ Connection Error with Hugging Face API: {e}")
            except Exception as e:
                print(f"❌ Unexpected Error: {e}")
        
        print("\n⏳ Waiting for the next batch of data...")
