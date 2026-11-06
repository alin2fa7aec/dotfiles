---
name: writing-style
description: Use when writing or editing Japanese prose — code comments, markdown documents, commit messages, any other Japanese text written into a file, or Japanese text the user will take out of the chat (reports or consultations sent to others, drafts pasted into issues or MRs).
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(grep *)
---

# 文章スタイル

次の日本語文章に適用する。

- ファイルに書き込む文章: コード内コメント、markdown 文書、コミットメッセージ
- チャットの外へ渡すための文章: 貼り付けて他人に送る報告や相談、issue や MR に転記する下書きなど、ユーザーがそのまま使う前提で書く本文

迷ったら適用する。チャットでのやりとりそのもの (説明、質問への回答) は対象外。  
UI に表示する文字列やテストデータは対象外。

## 規則

例と、判断に迷う場合の扱いは、同じディレクトリの `reference.md` にある。必要になったときだけ読む。

1. 記号は ASCII で書く。日本語の標準的な約物 (。、「」・) はそのまま使い、それ以外は ASCII で等価に表現できる限り ASCII を使う。矢印は `->`、括弧は `( )`、注記は「注:」、丸数字は `1.` と書く。em dash は使わず、文を分けるか「:」や ( ) で書き換える。全角英数字と全角スペースは半角にする。
2. 改行は文の切れ目でのみ。1行の長さに制限は設けず、折り返しを目的とした文中改行をしない。
3. 太字は見落とすと実害が出る箇所に限る。目安は1文書あたり0-2箇所。
4. 日本語と英単語の間には半角スペースを置く (「Docker のイメージ」)。数字と単位・助数詞の間は空けない (「1本」「30秒」「3.5mm」)。英字の単位を伴う数字は1つの英単語として扱い、前後の日本語との間を空ける (「CRC-32 の 4byte で」)。
5. 句読点は「、」「。」に統一する。列挙の区切りは ", " を使う。カタカナ語の末尾長音は付ける (エンコーダー、ユーザー)。
6. markdown 文書では型名/関数名/パス/コマンドをバッククォートで囲む。コード内コメントでは囲まなくてよい。
7. markdown 文書で段落の途中で行を分けるなら、行末にスペースを2つ書く。

## セルフチェック

Write と Edit で書き換えた markdown 文書とコメントを PostToolUse hook の `~/.claude/writing-lint.nu` が検査し、違反があれば差し戻す。  
指摘には `[スペース]` のような規則名が付く。直し方に迷ったら `reference.md` の同じ名前の節を読む。

コミットメッセージのように hook を通らない文章は、stdin から渡して同じ検査をかける。

```
<メッセージを出すコマンド> | nu --stdin ~/.claude/writing-lint.nu check
```

nu が無い環境では、`reference.md` の「nu が無い環境での検査」に従う。
