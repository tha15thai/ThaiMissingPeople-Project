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
