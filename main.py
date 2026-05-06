from fastapi import FastAPI, File, UploadFile, Header, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import tempfile
import os
import re
from typhoon_ocr import ocr_document

# สร้างแอป FastAPI
app = FastAPI(
    title="Police Report OCR API",
    description="API สำหรับสกัดข้อมูลจากใบแจ้งความคนหายด้วย Typhoon OCR",
    version="1.0.0"

)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # ยอมรับทุกเว็บไซต์ (หรือจะระบุแค่เว็บเพื่อนก็ได้)
    allow_credentials=False,
    allow_methods=["*"], # ยอมรับทุก Method (POST, GET, etc.)
    allow_headers=["*"], # ยอมรับทุก Header
)
# ==========================================
# Regex
# ==========================================
def extract_police_report_v2(text):
    text = re.sub(r'\s+', ' ', text).strip()
    data = {
        "reporter": { "name": None, "age": None, "id_card": None, "address": None, "phone": None },
        "missing_person": { "name": None, "age": None, "details": None }
    }

    split_point = re.search(r"(?:ได้?มา?พบ?พนักงานสอบสวน|แจ้งว่า)", text)
    if split_point:
        reporter_text = text[:split_point.start()]
        missing_text = text[split_point.end():]
    else:
        reporter_text = text
        missing_text = ""

    # ผู้แจ้ง
    match_r_name = re.search(r"(?:ข้าพเจ้า|ผู้แจ้ง|ชื่อ|^)\s*(?:นาย|นาง|นางสาว|น\.ส\.|ยศ\.|ด\.ต\.|ร\.ต\.อ\.)\s*([^\s0-9]+(?:\s+[^\s0-9]+)?)", reporter_text)
    if match_r_name: data["reporter"]["name"] = match_r_name.group(1).strip()
    match_r_age = re.search(r"อายุ\s*(\d{1,3})\s*ปี", reporter_text)
    if match_r_age: data["reporter"]["age"] = match_r_age.group(1)
    match_r_id = re.search(r"(\d{1}\s?-?\s?\d{4}\s?-?\s?\d{5}\s?-?\s?\d{2}\s?-?\s?\d{1})", reporter_text)
    if match_r_id: data["reporter"]["id_card"] = re.sub(r"[-\s]", "", match_r_id.group(1))
    match_r_addr = re.search(r"(?:ที่อยู่|อยู่บ้านเลขที่|พักอาศัย|อยู่บ้าน)\s*(.+?)(?=\s+(?:เบอร์|โทรศัพท์|เกี่ยวข้อง|ได้มา|มาพบ))", reporter_text)
    if match_r_addr: data["reporter"]["address"] = match_r_addr.group(1).strip()
    match_r_phone = re.search(r"(?:โทรศัพท์|เบอร์|โทร\.?|มือถือ)\s*[:.]?\s*(\d{2,3}[\s-]?\d{3}[\s-]?\d{4})", reporter_text)
    if match_r_phone: data["reporter"]["phone"] = re.sub(r"[-\s]", "", match_r_phone.group(1))

    # คนหาย
    match_m_name = re.search(r"(?:เด็กชาย|เด็กหญิง|ด\.ช\.|ด\.ญ\.|นาย|นาง|นางสาว|น\.ส\.|บ\.ส\.|บุตร|หลาน)\s*([^\s0-9]+(?:\s+[^\s0-9]+)?)", missing_text)
    if match_m_name: data["missing_person"]["name"] = match_m_name.group(1).strip()
    match_m_age = re.search(r"อายุ\s*(\d{1,3})\s*(?:ปี|ขวบ|เดือน)", missing_text)
    if match_m_age: data["missing_person"]["age"] = match_m_age.group(1)
    if match_m_name:
         start_detail = missing_text.find(match_m_name.group(1)) + len(match_m_name.group(1))
         data["missing_person"]["details"] = missing_text[start_detail:].strip()

    return data

# ==========================================
# สร้าง Endpoint สำหรับรับไฟล์และประมวลผล
# ==========================================
@app.post("/api/extract-report")
async def extract_report(
    file: UploadFile = File(..., description="ไฟล์ภาพใบแจ้งความ")
    # ลบการรับ Header x_api_key ออกไปเลย!
):
    # 1. เช็คว่า Backend มีการตั้งค่า API Key ไว้ในระบบหรือยัง
    backend_api_key = os.getenv("TYPHOON_API_KEY")
    if not backend_api_key:
        raise HTTPException(status_code=500, detail="Server Configuration Error: API Key is missing")

    # 2. ตั้งค่าให้ Typhoon นำ Key ไปใช้
    os.environ['TYPHOON_OCR_API_KEY'] = backend_api_key

    # 3. สร้างไฟล์ชั่วคราวเพื่อรอประมวลผล
    file_ext = file.filename.split('.')[-1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=f".{file_ext}") as tmp_file:
        content = await file.read()
        tmp_file.write(content)
        tmp_path = tmp_file.name

    try:
        # 4. ประมวลผลด้วย OCR
        markdown_result = ocr_document(
            pdf_or_image_path=tmp_path,
            task_type="default"
        )
        
        # 5. สกัดข้อมูลด้วย Regex
        extracted_data = extract_police_report_v2(markdown_result)

        # 6. คืนค่ากลับไปเป็น JSON
        return JSONResponse(content={
            "status": "success",
            "data": extracted_data,
            "raw_text": markdown_result
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"เกิดข้อผิดพลาดในการประมวลผล: {str(e)}")
    
    finally:
        # 7. ลบไฟล์ชั่วคราวทิ้งทุกครั้งเพื่อป้องกันไฟล์ขยะล้น Server
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)