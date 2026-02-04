const notionToken = process.env.NOTION_TOKEN;
const databaseId = process.env.NOTION_DATABASE_ID;

if (!notionToken || !databaseId) {
  console.error("Missing NOTION_TOKEN or NOTION_DATABASE_ID");
  process.exit(1);
}

async function main() {
  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${notionToken}`,
      "Notion-Version": "2022-06-28",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      parent: { database_id: databaseId },
      properties: {
        プロジェクト名: {
          title: [{ text: { content: "GitHub Actions ping" } }],
        },
        ステータス: {
          select: { name: "進行中" },
        },
        説明・詳細: {
          rich_text: [{ text: { content: "Hello from GitHub Actions ✅" } }],
        },
        開始日: {
          date: { start: new Date().toISOString() },
        },
      },
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    console.error(data);
    process.exit(1);
  }

  console.log("Created page:", data.id);
}

main();

