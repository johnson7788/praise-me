import uuid
import os
import logging
from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException, UploadFile, Form, Depends,Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from gtts import gTTS
import openai
from dotenv import load_dotenv
import uvicorn
from pydantic import BaseModel
from typing import Optional, List
import aiomysql
from aiomysql import Pool

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(levelname)s] - %(module)s - %(funcName)s - %(message)s",
    handlers=[
        logging.StreamHandler()
    ]
)

# 加载环境变量
load_dotenv(dotenv_path=".env")

# 数据库模型
class User(BaseModel):
    user_id: str
    username: str

class PraiseRecord(BaseModel):
    record_id: str
    user_id: str
    praise_type: str
    content: str
    style: Optional[str] = None
    created_at: datetime

class ChallengeRecord(BaseModel):
    challenge_id: str
    user_id: str
    challenge_type: str
    completed_at: datetime

# 初始化FastAPI
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 环境变量
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME")
LLM_BASE_URL = os.getenv("LLM_BASE_URL")
LLM_API_KEY = os.getenv("LLM_API_KEY")
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT")),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "db": os.getenv("DB_NAME"),
    "autocommit": True
}

# 数据库连接池
pool: Pool = None

LANGUAGE_MAP = {
    "zh": "中文",
    "en": "English",
    "ja": "Japanese",
    "ko": "Korean"
}

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 服务器启动中...")
    global pool
    pool = await aiomysql.create_pool(**DB_CONFIG)
    # 这里可以进行数据库连接、初始化缓存等
    yield  # 这里是 FastAPI 运行的时间
    print("🛑 服务器正在关闭...")
    # 这里可以进行清理操作，比如关闭数据库连接等
    pool.close()
    await pool.wait_closed()

# 通用生成逻辑
async def generate_praise_logic(input_text: str, style: str = "normal", language: str = "zh"):
    """
    生成夸夸的内容
    input_text: 用户输入
    """
    styles = {
        "normal": "温暖真诚",
        "funny": "幽默搞笑",
        "poetic": "唐诗宋词风格",
        "zhonger": "中二热血语气",
        "domineering": "霸道总裁口吻"
    }
    language_name = LANGUAGE_MAP.get(language, "中文")
    logging.info(f"用户输入{input_text}，风格{style}，语言{language_name}")
    try:
        client = openai.OpenAI(api_key=LLM_API_KEY, base_url=LLM_BASE_URL)
        prompt = f"""你是一个专业夸夸助手，根据以下要求生成鼓励：
        输入内容：{input_text}
        风格要求：{styles.get(style, styles['normal'])}
        输出要求：100字以内，使用{language_name}，避免敏感词
        """
        response = client.chat.completions.create(
            model=LLM_MODEL_NAME,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )
        content = response.choices[0].message.content
        logging.info(f"模式: {style}, 输入{input_text}，生成结果: {content}")
        result = {"text": content}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(500, f"生成失败: {str(e)}")

async def analyze_image(image_path: str) -> str:
    """调用图像识别API生成描述"""
    # 这里需要实现具体的图像识别逻辑，例如使用GPT-4V或CLIP
    return "一张充满活力的照片，展现出积极向上的生活态度"

# 数据库操作类
class Database:
    @staticmethod
    async def execute_query(query, params=None):
        async with pool.acquire() as conn:
            async with conn.cursor() as cur:
                await cur.execute(query, params or ())
                return cur

# 核心功能API
class PraiseRequest(BaseModel):
    text: Optional[str] = None
    style: str = "normal"
    language: Optional[str] = "zh" # 默认为中文,可选其它语言，例如日语，英语等

class DirectRequest(BaseModel):
    language: Optional[str] = "zh"

@app.post("/direct-praise")
async def direct_praise(request: DirectRequest):
    """直接夸模式"""
    default_prompt = "请随机生成一个正能量的夸赞，面向普通用户的日常鼓励"
    return await generate_praise_logic(default_prompt, language=request.language)

@app.post("/hint-praise")
async def hint_praise(request: PraiseRequest):
    """提示夸模式"""
    if not request.text:
        raise HTTPException(400, "请输入提示内容")
    return await generate_praise_logic(request.text, request.style)

@app.post("/photo-praise")
async def photo_praise(
    file: UploadFile,
    style: str = Form("normal")
):
    """拍拍夸模式"""
    try:
        # 保存上传文件
        file_path = f"static/uploads/{uuid.uuid4()}.jpg"
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        
        # 调用图像识别API
        image_desc = await analyze_image(file_path)
        return await generate_praise_logic(image_desc, style)
    except Exception as e:
        raise HTTPException(500, f"图片处理失败: {str(e)}")

@app.post("/style-praise")
async def style_praise(request: PraiseRequest):
    """风格夸模式"""
    return await generate_praise_logic(request.text, request.style)

# 语音生成
@app.post("/generate-voice")
async def generate_voice(text: str = Form(...)):
    try:
        filename = f"static/audio/{uuid.uuid4()}.mp3"
        tts = gTTS(text=text, lang='zh-cn')
        tts.save(filename)
        return FileResponse(filename, media_type="audio/mpeg")
    except Exception as e:
        raise HTTPException(500, f"语音生成失败: {str(e)}")

# 社区互动API
@app.post("/challenge/complete")
async def complete_challenge(user_id: str = Form(...), challenge_type: str = Form(...)):
    """完成每日挑战"""
    try:
        await Database.execute_query(
            "INSERT INTO challenges (challenge_id, user_id, challenge_type) VALUES (%s, %s, %s)",
            (str(uuid.uuid4()), user_id, challenge_type)
        )
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(500, f"记录挑战失败: {str(e)}")

@app.get("/leaderboard")
async def get_leaderboard(period: str = "daily"):
    """获取夸夸排行榜"""
    time_filter = {
        "daily": datetime.now() - timedelta(days=1),
        "weekly": datetime.now() - timedelta(weeks=1),
        "monthly": datetime.now() - timedelta(days=30)
    }.get(period, datetime.now() - timedelta(days=1))
    
    try:
        async with pool.acquire() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute("""
                    SELECT user_id, COUNT(*) as praise_count 
                    FROM praise_records 
                    WHERE created_at > %s
                    GROUP BY user_id 
                    ORDER BY praise_count DESC 
                    LIMIT 20
                """, (time_filter,))
                result = await cur.fetchall()
                return {"leaderboard": result}
    except Exception as e:
        raise HTTPException(500, f"获取排行榜失败: {str(e)}")

@app.api_route("/ping", methods=["GET", "POST"])
async def ping(request: Request):
    return "Pong"

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=6002)