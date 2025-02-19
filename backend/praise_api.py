import uuid
import os
import logging
import base64
from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException, UploadFile, Form, Depends,Request,File,Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from gtts import gTTS
import requests
import openai
from dotenv import load_dotenv
import uvicorn
from pydantic import BaseModel
from typing import Optional, List
import aiomysql
import aiofiles
from aiomysql import Pool
from zhipuai import ZhipuAI
from star_config import STAR_CONFIG

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(levelname)s] - %(module)s - %(funcName)s - %(message)s",
    handlers=[
        logging.StreamHandler()
    ]
)

# 加载环境变量
load_dotenv(dotenv_path=".env")
IMAGE_SAVE_DIR = "static/images"

# 数据库模型

class PraiseRecord(BaseModel):
    record_id: str  #唯一值，例如UUID
    praise_type: str
    content: str
    style: str
    likes: int  #喜欢的数量
    created_at: datetime


# 环境变量
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME")
LLM_BASE_URL = os.getenv("LLM_BASE_URL")
LLM_API_KEY = os.getenv("LLM_API_KEY")
VISION_MODEL_NAME = os.getenv("VISION_MODEL_NAME")
VISION_API_KEY = os.getenv("VISION_API_KEY")
GENIMG_MODEL_NAME = os.getenv("GENIMG_MODEL_NAME")
GENIMG_API_KEY = os.getenv("GENIMG_API_KEY")
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
        "domineering": "霸道总裁口吻",
        "original": "人物风格"
    }
    language_name = LANGUAGE_MAP.get(language, "中文")
    logging.info(f"用户输入{input_text}，风格{style}，语言{language_name}")
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
    return content


async def analyze_image_video(file_path: str, language: str = "zh") -> str:
    """调用图像识别和视频API生成描述
    file_path: 图片或者视频
    """
    # 判断是图片还是视频
    with open(file_path, 'rb') as img_video_file:
        file_base = base64.b64encode(img_video_file.read()).decode('utf-8')
    file_type = "video"
    if file_path.endswith((".jpg", ".jpeg", ".png")):
        file_type = "image"
        prompt = f"根据这个图片，对我进行夸赞，要求输出语言是: {language}"
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": file_base
                        }
                    },
                    {
                        "type": "text",
                        "text": prompt
                    }
                ]
            }
        ]
    else:
        prompt = f"根据这个视频，对我进行夸赞，要求输出语言是: {language}"
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "video_url",
                        "video_url": {
                            "url": file_base
                        }
                    },
                    {
                        "type": "text",
                        "text": prompt
                    }
                ]
            }
        ]
    language_name = LANGUAGE_MAP.get(language, "中文")
    logging.info(f"用户提交的文件类型是{file_type}，语言{language_name}")
    client = ZhipuAI(api_key=VISION_API_KEY)
    response = client.chat.completions.create(
        model=VISION_MODEL_NAME,  # 填写需要调用的模型名称
        messages=messages
    )
    content = response.choices[0].message.content
    logging.info(f"模式: {file_type}, 输入{file_path}，生成结果: {content}")
    return content

async def generate_image(prompt: str) -> str:
    """根据prompt生成图片
    """
    client = ZhipuAI(api_key=GENIMG_API_KEY)
    response = client.images.generations(
        model=GENIMG_MODEL_NAME,  # 填写需要调用的模型编码
        prompt=prompt,
    )
    img_url = response.data[0].url
    logging.info(f"根据提示词{prompt}生成图片成功，图片地址: {img_url}")
    # 1. 下载图片
    try:
        img_content = requests.get(img_url, stream=True)
        img_content.raise_for_status()  # 检查请求是否成功

        # 2. 生成唯一文件名和文件路径
        os.makedirs(IMAGE_SAVE_DIR, exist_ok=True)  # 确保目录存在
        image_filename = os.path.basename(img_url)
        image_filepath = os.path.join(IMAGE_SAVE_DIR, image_filename)
        # 3. 保存图片到本地
        with open(image_filepath, 'wb') as f:
            for chunk in img_content.iter_content(chunk_size=8192):
                f.write(chunk)
        logging.info(f"图片已保存到本地: {image_filepath}")
        # 4. 返回前端可访问的图片路径 (相对路径)
        return image_filepath  # 将 Windows 路径分隔符替换为 URL 兼容的 /

    except requests.exceptions.RequestException as e:
        logging.error(f"下载图片失败: {e}")
        return ""  # 下载失败返回空字符串或者抛出异常，根据你的需求处理
    except OSError as e:
        logging.error(f"保存图片失败: {e}")
        return ""  # 保存失败返回空字符串或者抛出异常，根据你的需求处理


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
    role: Optional[str] = None
    language: Optional[str] = "zh" # 默认为中文,可选其它语言，例如日语ja，英语,en等


class DirectRequest(BaseModel):
    language: Optional[str] = "zh"

@app.post("/direct-praise")
async def direct_praise(request: DirectRequest):
    """直接夸模式"""
    default_prompt = "请给我比较直白的夸奖，让我看到后满意大笑"
    try:
        content = await generate_praise_logic(default_prompt, language=request.language)
        result = {"text": content}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(500, f"生成失败: {str(e)}")
@app.post("/achievement-praise")
async def achievement_praise(request: AchievementRequest):
    """成就夸模式"""
    if not request.text:
        raise HTTPException(400, "请输入提示内容")
    try:
        content = await generate_praise_logic(request.text, language=request.language)
        result = {"text": content}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(500, f"生成失败: {str(e)}")

@app.post("/photo-praise")
async def photo_praise(
        file: UploadFile = File(..., description="上传的图片或视频文件"),
        language: str = Form("zh", description="语言代码 (zh/en/ja)")
):
    """拍拍夸模式，支持上传图片或视频"""
    # 定义允许的文件类型
    allowed_extensions = {"jpg", "jpeg", "png", "mp4"}

    # 验证文件类型
    file_extension = file.filename.split(".")[-1].lower() if "." in file.filename else ""
    if file_extension not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type. Supported types: {', '.join(allowed_extensions)}"
        )
    # 生成唯一文件名
    unique_id = uuid.uuid4()
    save_path = f"static/uploads/{unique_id}.{file_extension}"
    # 异步保存文件
    try:
        async with aiofiles.open(save_path, "wb") as buffer:
            while content := await file.read(1024 * 1024):  # 分块读取1MB
                await buffer.write(content)
    except Exception as e:
        logging.error(f"File save failed: {str(e)}")
        raise HTTPException(500, "File upload failed")
    # 调用多模态模型
    try:
        content = await analyze_image_video(save_path, language)
        result = {"text": content}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        logging.error(f"Analysis failed: {str(e)}")
        raise HTTPException(500, "Analysis failed")
    finally:
        # 生产环境建议添加文件清理逻辑
        pass

@app.post("/star-praise")
async def star_praise(request: StarRequest):
    """明星夸模式"""
    default_prompt = "请给我比较直白的夸奖，让我看到后满意大笑，并且在夸奖的开头加上我是xxx，并且话语风格和人物相符合"
    try:
        content = await generate_praise_logic(default_prompt, role=request.role,style="original",language=request.language)
        result = {"text": content}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(500, f"生成失败: {str(e)}")

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

# 语音生成
@app.post("/generate-animate")
async def generate_animate(request: Request):
    try:
        json_data = await request.json()
        text = json_data["text"]
        img_url = await generate_image(text)
        result = {"img_url": img_url}
        return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        raise HTTPException(500, f"生成动图失败: {str(e)}")

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

@app.get("/star-info")
async def get_star_info(
    language: Optional[str] = Query(None, description="按语言筛选(zh/en/ja等)"),
    limit: Optional[int] = Query(None, description="返回数量限制")
):
    """获取可选的明星列表"""
    filtered = STAR_CONFIG
    # 自动加上id属性，根据顺序
    for i, star in enumerate(STAR_CONFIG):
        star["id"] = i + 1
    if language:
        filtered = [s for s in filtered if s["language"] == language]
    if limit and limit > 0:
        filtered = filtered[:limit]
    return {"stars": filtered}

# 1. 新增Pydantic模型（添加到原有模型后面）
class CommentRequest(BaseModel):
    content: str

# 2. 新增评论接口（添加到现有接口后面）
@app.get("/comments/{record_id}")
async def get_comments(record_id: str):
    """获取指定记录的评论列表"""
    try:
        async with pool.acquire() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute("""
                    SELECT comment_id, content, created_at 
                    FROM praise_comments 
                    WHERE record_id = %s 
                    ORDER BY created_at DESC
                """, (record_id,))
                comments = await cur.fetchall()
                # datetime格式需要转换成字符串
                for comment in comments:
                    comment["created_at"] = comment["created_at"].strftime("%Y-%m-%d %H:%M:%S")
                result = {"comments": comments}
                return JSONResponse(content=result, headers={"Content-Type": "application/json; charset=utf-8"})
    except Exception as e:
        logging.error(f"获取评论失败: {str(e)}")
        raise HTTPException(500, detail=f"获取评论失败: {str(e)}")

@app.post("/comments/{record_id}")
async def add_comment(record_id: str, request: CommentRequest):
    """添加新评论"""
    try:
        async with pool.acquire() as conn:
            async with conn.cursor() as cur:
                # 检查记录是否存在
                await cur.execute(
                    "SELECT 1 FROM praise_records WHERE record_id = %s",
                    (record_id,)
                )
                if not await cur.fetchone():
                    raise HTTPException(404, detail="记录不存在")

                # 插入评论
                await cur.execute(
                    "INSERT INTO praise_comments (record_id, content) VALUES (%s, %s)",
                    (record_id, request.content)
                )
                await conn.commit()
                return {"message": "评论添加成功"}
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"添加评论失败: {str(e)}")
        raise HTTPException(500, detail=f"添加评论失败: {str(e)}")


@app.get("/get-praise-record/{record_id}",response_model=PraiseRecord,responses={200: {"description": "成功获取夸赞记录"},404: {"description": "记录不存在"},500: {"description": "服务器内部错误"}})
async def get_praise_record(record_id: str):
    """
    通过record_id查询夸赞记录详情
    **参数**:
    - record_id: 记录的唯一标识符（路径参数）
    **返回**:
    - JSON对象包含字段：record_id, praise_type, content, style, likes, created_at
    """
    try:
        async with pool.acquire() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute(
                    "SELECT record_id, praise_type, content, style,`likes`, created_at "
                    "FROM praise_records WHERE record_id = %s",
                    (record_id,)
                )
                record = await cur.fetchone()
                if not record:
                    raise HTTPException(status_code=404, detail="记录不存在")
                # 转换datetime为字符串
                record['created_at'] = record['created_at'].strftime("%Y-%m-%d %H:%M:%S")
                return record
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"查询失败: {str(e)}")
        raise HTTPException(500, detail=f"查询失败: {str(e)}")

@app.api_route("/ping", methods=["GET", "POST"])
async def ping(request: Request):
    return "Pong"

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=6002)