# Police Report OCR API

API สำหรับระบบสกัดข้อมูลจากใบแจ้งความ (รายงานกรณีคนหาย) โดยอัตโนมัติ พัฒนาด้วย **FastAPI** ร่วมกับ **Typhoon OCR** 

ระบบนี้ทำหน้าที่รับไฟล์ภาพหรือ PDF จากฝั่ง Frontend นำไปแปลงเป็นข้อความ (Image-to-Text) และใช้ Regular Expression (Regex) สกัดข้อมูลสำคัญออกมาเป็นรูปแบบ JSON ที่พร้อมนำไปใช้งานต่อในระบบ

## ✨ Tech Stack
- **Framework:** FastAPI
- **OCR Engine:** Typhoon OCR (SCB 10X)
- **Data Parsing:** Python `re` (Regex)
- **Server:** Uvicorn

---

## 🛠️ Setup & Installation

### 1. ความต้องการของระบบระดับ OS (สำหรับอ่าน PDF)
โปรเจกต์นี้ต้องการ `poppler-utils` ในการจัดการไฟล์ PDF
- **Ubuntu/Debian:** `sudo apt-get install poppler-utils`
- **macOS (Homebrew):** `brew install poppler`
- **Windows:** ต้องดาวน์โหลด Poppler binaries และเพิ่มลงใน System PATH

### 2. การติดตั้ง Library
โคลนโปรเจกต์และติดตั้ง Dependencies จาก `requirements.txt`
```bash
git clone <YOUR_REPO_URL>
cd <YOUR_PROJECT_FOLDER>
pip install -r requirements.txt
```



## 🔗 การเชื่อมต่อ API

ระบบนี้เชื่อมต่อกับ OCR Backend API ที่พัฒนาด้วย FastAPI โดยทำการดึงข้อมูลภาพและสกัดเป็นโครงสร้าง JSON 

- **Base URL (Production):** `https://police-ocr-api.onrender.com`
- **Swagger UI (สำหรับเทส API):** `https://police-ocr-api.onrender.com/docs`

### 📌 Endpoint
- **Path:** `/api/extract-report`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`

#### 📦 Request Payload (Body)
| Key | Type | Description |
| :--- | :--- | :--- |
| `file` | File | ไฟล์ภาพใบแจ้งความที่ต้องการสกัดข้อมูล (รองรับ `.jpg`, `.png`, `.pdf`) |

*หมายเหตุ: ไม่ต้องส่ง API Key ใน Header เนื่องจากระบบทำการจัดการรหัสความปลอดภัยไว้ในฝั่งเซิร์ฟเวอร์เรียบร้อยแล้ว*

#### 📤 Example Response Success 200 OK
เมื่อส่งไฟล์สำเร็จ ระบบจะส่งคืนโครงสร้างข้อมูล (JSON) สำหรับนำไปแสดงผลดังนี้:

```json
{
  "status": "success",
  "data": {
    "reporter": {
      "name": "สมชาย รักดี",
      "age": "45",
      "id_card": "1123456789012",
      "address": "99/8 หมู่ 5 ต.ตลาดขวัญ อ.เมือง จ.นนทบุรี",
      "phone": "0819998888"
    },
    "missing_person": {
      "name": "ใจดี รักดี",
      "age": "12",
      "details": "อายุ 12 ปี ได้หายออกจากบ้านพัก รูปร่างท้วม ผิวขาว ผมสั้น"
    }
  },
  "raw_text": "(ข้อความดิบที่ AI อ่านได้ทั้งหมด)"
}
