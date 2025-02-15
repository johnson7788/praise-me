夸夸我app的后端代码

# app下载路径
http://127.0.0.1:6002/static/app/android.app

# 目录结构
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

3. 拍拍夸赞（图片夸）
请求方式: POST
路径: /photo-praise
表单参数:
file (必填): 上传的图片文件（支持 jpg/png）
响应:
{
  "text": "基于图片分析的夸赞内容",
  "image_url": "/static/uploads/filename.jpg"
}
说明: 图片将保存至/static/uploads/目录

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
praise_type	string	是	夸赞类型（如：direct_praise）
content	string	是	夸赞内容
likes	int	是	喜欢数量（默认 1）
请求示例
{
  "record_id": "550e8400-e29b-41d4-a716-446655440000",
  "praise_type": "direct_praise",
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

6. 查询夸赞记录接口
接口描述
通过 UUID 查询对应的夸赞记录内容。

请求地址
GET /get-praise-record/{record_id}

请求方法：
GET

请求参数（Path）：
字段名	类型	必填	描述
record_id	string	是	夸赞记录的唯一标识（UUID）
请求示例：
GET /get-praise-record/550e8400-e29b-41d4-a716-446655440000

响应参数：
字段名	类型	描述
record_id	string	夸赞记录的唯一标识（UUID）
praise_type	string	夸赞类型（如：direct_praise）
content	string	夸赞内容
created_at	string	记录创建时间（ISO 8601 格式）

响应示例：
{
  "record_id": "550e8400-e29b-41d4-a716-446655440000",
  "praise_type": "direct_praise",
  "content": "你今天的表现真是太棒了！",
  "created_at": "2023-10-01T12:34:56Z"
}

错误响应：
HTTP 状态码	错误信息	描述
404	Not Found	记录不存在
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
