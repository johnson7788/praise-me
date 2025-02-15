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

class PraiseRecord(BaseModel):
    record_id: str  #唯一值，例如UUID
    praise_type: str
    content: str
    like: int  #喜欢的数量
    created_at: datetime


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

app = FastAPI(lifespan=lifespan)

app.mount("/static", StaticFiles(directory="static"), name="static")

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
# 通用生成逻辑
async def generate_praise_logic(input_text: str, role:str="我的好友", style: str = "normal", language: str = "zh"):
    """
    生成夸夸的内容
    input_text: 用户输入
    role: str: 用户角色，谁来夸我？男朋友，明星，总理
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
        prompt = f"""你的身份是{role}，请对我进行夸奖：
        输入内容：{input_text}
        风格要求：{styles.get(style, styles['normal'])}
        输出要求：100字以内，语言是：{language_name}
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
class AchievementRequest(BaseModel):
    text: Optional[str] = None
    language: Optional[str] = "zh" # 默认为中文,可选其它语言，例如日语，英语等

class StarRequest(BaseModel):
    text: Optional[str] = None
    role: Optional[str] = None
    language: Optional[str] = "zh" # 默认为中文,可选其它语言，例如日语，英语等


class DirectRequest(BaseModel):
    language: Optional[str] = "zh"

@app.post("/direct-praise")
async def direct_praise(request: DirectRequest):
    """直接夸模式"""
    default_prompt = "请给我比较直白的夸奖，让我看到后满意大笑"
    return await generate_praise_logic(default_prompt, language=request.language)

@app.post("/achievement-praise")
async def achievement_praise(request: AchievementRequest):
    """成就夸模式"""
    if not request.text:
        raise HTTPException(400, "请输入提示内容")
    return await generate_praise_logic(request.text, language=request.language)

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

@app.post("/star-praise")
async def star_praise(request: StarRequest):
    """明星夸模式"""
    return await generate_praise_logic(request.text, role=request.role, language=request.language)

class SavePraiseRequest(BaseModel):
    record_id: str
    praise_type: str
    content: str
    style: Optional[str] = "normal"
@app.post("/save-praise-record")
async def save_praise_record(request: SavePraiseRequest):
    """保存夸赞记录（喜欢或分享时调用）
    先查询，如果存在，那么更新likes+1，否则插入1条新的
    """
    try:
        created_at = datetime.now()
        async with pool.acquire() as conn:
            async with conn.cursor() as cur:
                # 先检查 record_id 是否存在
                await cur.execute(
                    "SELECT * FROM praise_records WHERE record_id = %s",
                    (request.record_id,)
                )
                existing_record = await cur.fetchone()

                if existing_record:
                    # 如果存在，则更新 likes
                    await cur.execute(
                        "UPDATE praise_records SET `likes` = `likes` + 1 WHERE record_id = %s",
                        (request.record_id,)
                    )
                else:
                    # 如果不存在，则插入新的记录
                    await cur.execute(
                        "INSERT INTO praise_records (record_id, praise_type, content, style,`likes`, created_at) "
                        "VALUES (%s, %s, %s, %s, %s, %s)",
                        (request.record_id, request.praise_type, request.content, request.style,1, created_at)
                    )

                # 提交事务
                await conn.commit()

        return {"message": "记录保存成功"}
    except Exception as e:
        logging.error(f"保存记录失败: {str(e)}")
        raise HTTPException(500, detail=f"保存失败: {str(e)}")

@app.get("/get-praise-record/{record_id}")
async def get_praise_record(record_id: str):
    """通过UUID查询夸赞内容"""
    try:
        async with pool.acquire() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute(
                    "SELECT record_id, praise_type, content, `likes`, created_at "
                    "FROM praise_records WHERE record_id = %s",
                    (record_id,)
                )
                record = await cur.fetchone()
                if not record:
                    raise HTTPException(status_code=404, detail="记录不存在")
                return record
    except Exception as e:
        raise HTTPException(500, detail=f"查询失败: {str(e)}")

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

# 社区排行
@app.get("/leaderboard")
async def get_leaderboard(period: str = "daily"):
    """获取夸夸排行榜,返回夸夸的record_id,praise_type,content,likes"""
    time_filter = {
        "daily": datetime.now() - timedelta(days=1),
        "weekly": datetime.now() - timedelta(weeks=1),
        "monthly": datetime.now() - timedelta(days=30)
    }.get(period.lower(), datetime.now() - timedelta(days=1))

    try:
        # 执行数据库查询（假设使用asyncpg异步驱动）
        async with pool.acquire() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute("""
                    SELECT record_id, praise_type, content, likes 
                    FROM praise_records 
                    WHERE created_at >= %s
                    ORDER BY likes DESC
                    LIMIT 100
                """, (time_filter,))
                result = await cur.fetchall()
                if not result:
                    raise HTTPException(status_code=404, detail="No leaderboard data found for the selected period.")
        result = [dict(record) for record in result]
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        logging.error(f"获取排行榜失败: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"获取排行榜失败: {str(e)}"
        ) from e

@app.post("/add-praise-like")
async def add_praise_like(request: Request):
    """增加指定记录的like数（记录存在时likes+1，记录不存在返回错误）"""
    json_data = await request.json()
    record_id = json_data.get("record_id")
    try:
        async with pool.acquire() as conn:
            async with conn.cursor() as cur:
                # 检查 record_id 是否存在
                await cur.execute(
                    "SELECT * FROM praise_records WHERE record_id = %s",
                    (record_id,)
                )
                existing_record = await cur.fetchone()

                if existing_record:
                    # 如果记录存在，更新 likes 数量
                    await cur.execute(
                        "UPDATE praise_records SET `likes` = `likes` + 1 WHERE record_id = %s",
                        (record_id,)
                    )
                    await conn.commit()
                    return {"message": "Like 增加成功"}
                else:
                    # 如果记录不存在，返回错误
                    logging.error(f"{record_id}: 记录不存在")
                    raise HTTPException(status_code=404, detail="记录不存在")
    except Exception as e:
        logging.error(f"{record_id}: 增加 like 失败: {str(e)}")
        raise HTTPException(500, detail=f"增加失败: {str(e)}")

@app.api_route("/ping", methods=["GET", "POST"])
async def ping(request: Request):
    return "Pong"

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=6002)