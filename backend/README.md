夸夸我app的后端代码

# app下载路径
http://127.0.0.1:6002/static/app/android.app

# 目录结构
static:
    app: 存储生的应用
        PraiseMe.apk
        PraiseMe.dmg
    audio：
        存储生成的夸夸音频
    head:
        明星头像
    images:
        存储生成的夸夸图片
    uploads：
        用户上传的文件
db_init.py  //数据库初始化
test_api.py  //测试文件
.env 文件内容:
LLM_MODEL_NAME=glm-4-flash
LLM_BASE_URL=https://open.bigmodel.cn/api/paas/v4/
LLM_API_KEY=xxx

DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
DB_NAME=praiseme

# 后端代码
praise_api.py  //主程序文件


# 后端接口
核心功能 - AI 夸夸模式
1. 直接夸赞
请求方式: POST
路径: /direct-praise
参数: 无
响应:
{
  "text": "随机生成的暖心夸赞内容"
}
说明: 无需任何输入，直接获得 AI 生成的随机夸赞

2. 成就夸赞
请求方式: POST
路径: /achievement-praise
表单参数:
text (必填): 用户输入的(屁大点，😄)成就内容
响应:
{
  "text": "根据提示生成的成就夸赞内容",
  "language": "zh" // 语言类型，默认zh, 可以为en，ja
}
示例请求:
curl -X POST \
  -F "text=今天学会了游泳" \
  -F "style=poetic" \
  http://api.example.com/achievement-praise

3. 拍拍夸（图片和视频夸）
接口路径：/photo-praise
请求方式：POST
Content-Type：multipart/form-data
响应格式：JSON

请求参数
参数名	位置	类型	必填	说明
file	form	file	是	上传的图片/视频文件（支持格式见下表）
language	form	string	否	语言代码 (默认zh，支持en/ja)
支持文件格式：
图片：jpg/jpeg/png
视频：mp4

响应示例
成功响应 (200):
{
  "text": "这张照片里的你散发着自信的光芒，连阳光都为你喝彩！"
}
错误响应 (400):
{
  "detail": "Unsupported file type. Supported types: jpg, jpeg, png, mp4"
} 

4. 调用示例
使用 cURL:
curl -X POST "http://localhost:6002/photo-praise" \
  -F "file=@selfie.jpg" \
  -F "language=en"

4. 语音生成
请求方式: POST
路径: /generate-voice
表单参数:
text (必填): 需要转换为语音的文本
响应:
audio/mpeg 音频文件
示例用法:
<audio controls>
  <source src="http://api.example.com/generate-voice" type="audio/mpeg">
</audio>

5.保存夸赞记录接口
接口描述
用户点击“喜欢”或“分享”时，将当前生成的夸赞内容和随机生成的 UUID 发送到后端，后端保存这条记录。
请求地址
POST /save-praise-record
请求方法
POST
请求头
Content-Type: application/json

请求参数（Body）
字段名	类型	必填	描述
record_id	string	是	夸赞记录的唯一标识（UUID）
praise_type	string	是	夸赞类型（如：'direct', 'achievement', 'photo', 'star', 'animate'）
content	string	是	夸赞内容, 或者animate的话，是图片的名称或者url
likes	int	是	喜欢数量（默认 1）
请求示例
{
  "record_id": "550e8400-e29b-41d4-a716-446655440000",
  "praise_type": "direct",
  "content": "你今天的表现真是太棒了！",
  "likes": 1
}
响应参数
字段名	类型	描述
message	string	接口返回的消息
响应示例
{
  "message": "记录保存成功"
}
错误响应
HTTP 状态码	错误信息	描述
400	Bad Request	请求参数缺失或格式错误
500	Internal Server Error	服务器内部错误（如数据库异常）

# 7.夸夸排行榜
请求路径
URL: /leaderboard
方法: GET
查询参数:
period (可选): 排行榜周期类型，默认为 daily，支持以下值：
daily: 获取过去 1 天的排行榜
weekly: 获取过去 1 周的排行榜
monthly: 获取过去 1 个月的排行榜
请求示例
GET /leaderboard?period=daily
响应
状态码:
200 OK: 请求成功，返回排行榜数据。
404 Not Found: 如果查询的时间段内没有数据。
500 Internal Server Error: 服务器内部错误（例如，数据库查询失败）。

响应格式 (成功)：
Content-Type: application/json
响应体是一个 JSON 数组，包含以下字段：
record_id: 夸赞记录的唯一标识符 (UUID)
praise_type: 夸赞类型（如“direct”，“achievement”等）
content: 夸赞的内容
likes: 该夸赞记录的点赞数量
示例：
[
  {
    "record_id": "abc123",
    "praise_type": "direct",
    "content": "你是最棒的！",
    "likes": 120
  },
  {
    "record_id": "def456",
    "praise_type": "achievement",
    "content": "你完成了伟大的成就！",
    "likes": 100
  }
]

8.给praise的record_id增加like+1
接口名称: /add-praise-like
请求方法: POST
请求体: record_id (字符串，表示要增加 like 的记录的 ID)
返回内容: JSON 格式的响应，包含一个消息字段 message，告知操作成功与否。
2. 请求示例
POST /add-praise-like HTTP/1.1
Content-Type: application/json

{
    "record_id": "abc123"
}
3. 成功响应
{
    "message": "Like 增加成功"
}
4. 错误响应
记录不存在:
{
    "detail": "记录不存在"
}
服务器错误:
{
    "detail": "增加失败: <具体错误>"
}

6.
GET /star-info
功能：获取明星信息列表
参数：
language：过滤指定语言的明星（如zh/en）
limit：限制返回数量

响应示例：
{
    "stars": [
        {
            "name": "周杰伦",
            "language": "zh",
            "spkid": "Zhoujielun",
            "sex": "male",
            "img": "https://pic1.imgdb.cn/item/67b4810bd0e0a243d4008dc9.jpg",
            "id": 1
        },
        {
            "name": "Taylor Swift",
            "language": "en",
            "spkid": "Taylor",
            "sex": "female",
            "img": "https://pic1.imgdb.cn/item/67b49009d0e0a243d4009152.jpg",
            "id": 2
        }
    ]
}


###  /star-praise (明星夸模式)

**接口描述:**

该接口用于生成明星风格的夸赞内容，并返回夸赞文本和语音文件地址。用户可以选择不同的明星角色和语言来定制夸赞。

**HTTP 方法:** `POST`

**请求 URL:**  `${API_HOST}/star-praise`

**请求类型:** `application/json`

**请求参数:**

请求体 (JSON 格式):
{
  "role": "string",  // 明星角色名称，例如 "Elon Musk", "Taylor Swift"。 如果不提供，后端可能使用默认角色。
  "spkid": "zhoujielun", //必须提供，声音id
  "language": "string" // 语言代码，用于指定夸赞文本和语音的语言。
                     // 支持的语言代码包括:
                     // "zh" - 中文 (默认)
                     // "en" - 英语
                     // "ja" - 日语
}
响应体 (JSON 格式):
JSON
{
  "text": "string",      // AI 生成的夸赞文本
  "audio_url": "string" // 夸赞语音文件的 URL, 语音文件存储在服务器的 static/audio 目录下，
                         // 例如: "/static/audio/xxxx.wav"。
                         // 如果语音生成失败，该字段可能为空字符串。
}


POST /generate-animate
描述: 该接口接收一个文本提示，并生成一张图片，返回图片的URL。
content-type	application/json
请求参数:
text (必选): 需要根据此文本生成图片的提示。
请求示例:
{
    "text": "A beautiful sunset over the mountains"
}
响应:
200 OK: 成功生成图片，返回图片URL。
{
    "img_url": "https://example.com/generated_image.jpg"
}
500 Internal Server Error: 生成图片失败。
{
    "detail": "生成动图失败: <错误信息>"
}

CosyVoice外部接口：
POST /api/inference_sft
描述：根据指定的说话人ID和文本进行语音合成。

请求体：
{
  "tts_text": "你好",
  "spk_id": "中文女"
}
tts_text：要进行TTS的文本。（必填）
spk_id：说话人ID。（必填）
响应：

返回生成的语音文件 sound.wav。
Content-Type: audio/wav
Content-Disposition: attachment; filename="sound.wav"

2. POST /api/tts
描述：根据语言选择说话人ID，并生成语音。

请求体：
{
  "tts_text": "Hello, world!",
  "language": "en"
}
tts_text：要进行TTS的文本。（必填）
language：选择的语言，支持 zh, en, ja, ko 等。（必填）
响应：

返回生成的语音文件 sound.wav。
Content-Type: audio/wav
Content-Disposition: attachment; filename="sound.wav"


## 评论接口文档

### 1. 获取评论列表
**URL**: `/comments/{record_id}`  
**方法**: GET  
**参数**:
- `record_id` (路径参数): 夸夸记录ID
**成功响应**:
```json
{
  "comments": [
    {
      "comment_id": 1,
      "content": "这个夸夸太棒了！",
      "created_at": "2024-03-20T10:30:00"
    }
  ]
}
添加评论
URL: /comments/{record_id}
方法: POST
参数:
record_id (路径参数): 夸夸记录ID
请求体:
{
  "content": "评论内容"
}
成功响应:
{
  "message": "评论添加成功"
}
错误响应:
404: 当record_id不存在时
400: 当content为空时


### GET /get-praise-record/{record_id}
#### 功能描述
通过记录ID查询夸赞记录的详细信息

#### 请求参数
| 参数名     | 位置   | 类型   | 必填 | 说明                 |
|------------|--------|--------|------|----------------------|
| record_id  | path   | string | 是   | 夸赞记录的唯一标识符 |

#### 响应信息
**成功响应 (200 OK)**
```json
{
    "record_id": "550e8400-e29b-41d4-a716-446655440000",
    "praise_type": "direct",
    "content": "你真是才华横溢！",
    "style": "normal",
    "likes": 3,
    "created_at": "2024-02-20 14:30:45"
}