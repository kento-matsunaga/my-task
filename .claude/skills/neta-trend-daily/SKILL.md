---
name: neta-trend-daily
description: Daily tech/AI trend digest. Fetches trending articles from Hatena Bookmark (AI + Technology) and Hacker News, rates them by interest level, and outputs a markdown report to the repo's daily/ directory
user-invocable: true
disable-model-invocation: true
allowed-tools: WebFetch, Bash(*), Write, Read, Glob
---

# Neta Trend Daily

あなたは、ユーザー専用のデイリーテックトレンドダイジェストを作成するエージェントです。
以下の手順に厳密に従って、トレンド記事を収集・評価・出力してください。

## 興味プロファイル

[interests.md](interests.md) を参照して、ユーザーの興味領域と評価基準を把握してください。

## Step 1: はてなブックマーク記事の取得

### 1-A: テクノロジーのホットエントリ取得

WebFetch で以下のRSSを取得してください:

```
https://b.hatena.ne.jp/hotentry/it.rss
```

RSSから以下を抽出:
- 記事タイトル
- 記事URL
- ブックマーク数 (`hatena:bookmarkcount`)
- 公開日

### 1-B: AI特化 と テクノロジー全般 に分類

取得した記事を以下のキーワードでフィルタし、2つのグループに分けてください:

**AI特化グループ** (以下のキーワードがタイトルまたは概要に含まれる):
`AI`, `人工知能`, `LLM`, `GPT`, `Claude`, `Gemini`, `ChatGPT`, `機械学習`, `深層学習`, `生成AI`, `RAG`, `エージェント`, `Copilot`, `Cursor`, `バイブコーディング`, `vibe coding`, `プロンプト`, `ファインチューニング`, `transformer`, `diffusion`, `Stable Diffusion`, `Midjourney`

**テクノロジー全般グループ**: AI特化に該当しない残りの記事

それぞれブックマーク数の降順でソートし、上位10件ずつを選定してください。

## Step 2: Hacker News 記事の取得

Bash で以下のコマンドを実行して Top Stories の ID リストを取得:

```bash
curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json' | python3 -c "import sys,json; ids=json.load(sys.stdin)[:30]; print('\n'.join(map(str,ids)))"
```

次に各記事の詳細を取得（上位30件を取得し、後で10件に絞り込む）:

```bash
for id in $(上記のID); do
  curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json"
done
```

各記事から以下を抽出:
- title
- url
- score (points)
- HN discussion URL: `https://news.ycombinator.com/item?id={id}`

Points の降順でソートし、上位10件を選定してください。

## Step 3: 興味度の評価

[interests.md](interests.md) の興味プロファイルに基づき、各記事に1〜5の興味度を付与してください。

**評価基準**:
- ★★★★★ (5): 興味領域に直接ヒット。すぐ読むべき
- ★★★★☆ (4): 強く関連。読む価値が高い
- ★★★☆☆ (3): やや関連。時間があれば読みたい
- ★★☆☆☆ (2): 間接的に関連。スキップ可
- ★☆☆☆☆ (1): 興味領域外だがトレンドとして注目

各セクション内で興味度の降順 → 同点ならブクマ数/Points降順でソートし直してください。

## Step 4: Markdown ファイルの出力

まず、Bash で出力先のリポジトリルートを特定してください:

```bash
REPO_ROOT="$(cd "$(readlink ~/.claude/skills/neta-trend-daily)/../../.." && pwd)"
echo "$REPO_ROOT"
```

以下のフォーマットで `${REPO_ROOT}/daily/YYYY-MM-DD.md` に出力してください。
日付は今日の日付を使用。ファイルが既に存在する場合は上書きしてください。
`daily/` ディレクトリが存在しない場合は作成してください。

```markdown
# Neta Trend Daily - YYYY-MM-DD

> Generated at HH:MM JST

## Hatena Bookmark - AI/LLM

| # | 記事 | ブクマ | 興味度 | 要約 |
|---|------|--------|--------|------|
| 1 | [記事タイトル](URL) | 342 | ★★★★★ | 1行要約をここに |
| 2 | [記事タイトル](URL) | 218 | ★★★★☆ | 1行要約をここに |
...（10件）

## Hatena Bookmark - テクノロジー全般

| # | 記事 | ブクマ | 興味度 | 要約 |
|---|------|--------|--------|------|
| 1 | [記事タイトル](URL) | 156 | ★★★★☆ | 1行要約をここに |
...（10件）

## Hacker News

| # | Article | Pts | 興味度 | 要約 |
|---|---------|-----|--------|------|
| 1 | [Article Title](URL) | 523 | ★★★★★ | 1行要約をここに |
...（10件）

---
Sources: Hatena Bookmark Hot Entry (Technology), Hacker News Top Stories
```

### 出力ルール

- 要約は30文字以内で記事の本質を端的に（すべて日本語で記載。HN記事も日本語で要約する）
- ★は全角文字で `★★★★★` `★★★★☆` `★★★☆☆` `★★☆☆☆` `★☆☆☆☆` を使用
- テーブルのアラインメントを揃えること

## Step 5: 完了報告

出力が完了したら、以下のサマリーをユーザーに表示してください:

```
Neta Trend Daily (YYYY-MM-DD) を作成しました。
  -> ${REPO_ROOT}/daily/YYYY-MM-DD.md

ハイライト:
- [AI特化で最も興味度が高い記事のタイトル] ★★★★★
- [テクノロジー全般で最も興味度が高い記事のタイトル] ★★★★★
- [HNで最も興味度が高い記事のタイトル] ★★★★★
```
