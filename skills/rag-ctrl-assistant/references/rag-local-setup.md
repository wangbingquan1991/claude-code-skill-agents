# 本地 RAG 搭建指南（可选增强）

> 纯静态HTML知识库已能满足90%的检索需求。以下方案用于需要语义搜索和LLM问答的场景。
> 诚实声明：这些组件独立于静态知识库，需要额外的安装和维护。

## 何时需要向量RAG？

| 场景 | 纯静态 | 加向量RAG |
|------|--------|----------|
| 关键字搜索 | ✅ Lunr.js | ✅ |
| 按领域/标签过滤 | ✅ index.html | ✅ |
| 双向链接跳转 | ✅ | ✅ |
| 语义相似搜索 | ❌ | ✅ |
| 自然语言问答 | ❌ | ✅ |
| 跨文档概念关联 | ❌ | ✅ |
| 自动摘要建议 | ❌ | ✅ |

**建议**：先用纯静态方案运行3个月。如果发现「知道有相关信息但搜不到」的频率 > 每周3次，再考虑添加向量层。

## 本地 RAG 最小架构

```
用户输入 → 嵌入模型 → 向量检索 → 上下文组装 → 本地LLM生成 → 答案
              ↑                        ↑
         知识库文档                   向量数据库
```

## 技术栈推荐

### 嵌入模型
| 模型 | 大小 | 速度 | 推荐场景 |
|------|------|------|---------|
| BGE-small-zh | 24MB | ⚡快 | 中文文档 |
| all-MiniLM-L6-v2 | 80MB | ⚡快 | 英文文档 |
| BGE-large-zh | 326MB | 中 | 高质量中文 |
| text2vec-large-chinese | 326MB | 中 | 中文语义 |

### 向量数据库
| 数据库 | 部署方式 | 适合数据量 | 特点 |
|--------|---------|----------|------|
| **Chroma** | pip安装 | < 50K 文档 | 最简，Python原生 |
| **FAISS** | pip安装 | < 1M 文档 | Meta出品，纯CPU也快 |
| **Qdrant** | Docker | 任意规模 | 功能全，有Edge版 |
| **LanceDB** | pip安装 | < 100K 文档 | 零配置，列式存储 |

### 本地LLM
| 模型 | VRAM需求 | 质量 | 速度 |
|------|---------|------|------|
| Gemma 4 E4B (Q4) | 6GB | ⭐⭐⭐ | ⚡快 |
| Llama 3.1 8B (Q4) | 6GB | ⭐⭐⭐⭐ | ⚡快 |
| Phi 3.5 mini (Q4) | 3GB | ⭐⭐⭐ | ⚡⚡极快 |
| Qwen 2.5 7B (Q4) | 6GB | ⭐⭐⭐⭐ | ⚡快 |

推荐：Ollama 运行 `ollama pull llama3.1:8b`

## 搭建步骤

### Step 1: 安装依赖
```bash
pip install chromadb sentence-transformers ollama
```

### Step 2: 构建向量索引
```python
# scripts/build_vector_index.py
import chromadb
from sentence_transformers import SentenceTransformer
from pathlib import Path

# 初始化
client = chromadb.PersistentClient(path="./vector_db")
collection = client.get_or_create_collection("knowledge_base")
model = SentenceTransformer("BAAI/bge-small-zh")

# 读取所有卡片
cards_dir = Path("~/RAG/02-cards").expanduser()
for md_file in cards_dir.rglob("*.md"):
    content = md_file.read_text()
    embedding = model.encode(content).tolist()
    collection.add(
        documents=[content],
        metadatas=[{"path": str(md_file)}],
        ids=[str(md_file.relative_to(cards_dir))]
    )
```

### Step 3: 构建问答接口
```python
# scripts/query.py
import ollama

def ask(question, top_k=5):
    # 1. 嵌入查询
    query_embedding = model.encode(question).tolist()
    
    # 2. 检索相关卡片
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k
    )
    
    # 3. 组装上下文
    context = "\n---\n".join(results["documents"][0])
    sources = [r["path"] for r in results["metadatas"][0]]
    
    # 4. LLM生成回答
    response = ollama.chat(model="llama3.1:8b", messages=[{
        "role": "user",
        "content": f"基于以下知识库内容回答问题。\n\n知识库：\n{context}\n\n问题：{question}\n\n回答时请引用来源。"
    }])
    
    return {
        "answer": response["message"]["content"],
        "sources": sources
    }
```

### Step 4: 集成到静态站
在卡片HTML页面中添加AI问答组件：
```html
<script>
async function askAI(question, cardContent) {
    const response = await fetch('http://localhost:11434/api/chat', {
        method: 'POST',
        body: JSON.stringify({
            model: 'llama3.1:8b',
            messages: [{
                role: 'user',
                content: `基于以下卡片内容回答：\n\n${cardContent}\n\n问题：${question}`
            }]
        })
    });
    // 解析并展示答案...
}
</script>
```

## 隐私增强方案

| 技术 | 作用 | 实现难度 |
|------|------|---------|
| 差分隐私嵌入 | 向量加噪，防逆向推导原文 | 中 |
| 同态加密检索 | 加密向量上直接计算相似度 | 高 |
| TEE执行 | 模型推理在安全飞地内 | 低(Apple Silicon) |
| PII预处理 | 索引前去敏感信息 | 低 |

**最低成本隐私方案**：所有组件（Chromadb + Ollama + 嵌入模型）100%本地运行，零网络依赖。

## 常见问题

**Q: 向量索引多久更新一次？**
A: 添加新卡片后运行 `python scripts/build_vector_index.py --incremental`

**Q: 纯静态和向量方案可以共存吗？**
A: 完全可以。静态方案是基础层（浏览、链接导航），向量方案是增强层（语义搜索、问答）。

**Q: 需要GPU吗？**
A: 嵌入模型可在CPU上运行（BGE-small 毫秒级）。LLM推理推荐GPU但非必需（Llama 3.1 8B Q4在M系列Mac CPU上可用）。
