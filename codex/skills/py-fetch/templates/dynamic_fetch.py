#!/usr/bin/env python3
"""动态页面抓取模板
用途: React/Vue/Next.js 等需要 JS 渲染的页面
替换: URL, WAIT_SELECTOR(可选), CSS_SELECTOR(可选)
"""
from scrapling.fetchers import DynamicFetcher

URL = "{{URL}}"
WAIT_SELECTOR = "{{WAIT_SELECTOR}}"  # 如 ".content-loaded"，不需要则留空
CSS_SELECTOR = "{{CSS_SELECTOR}}"    # 如 "article h1::text"，不需要则留空

page = DynamicFetcher.fetch(
    URL,
    headless=True,
    timeout=30000,
    network_idle=True,
    wait_selector=WAIT_SELECTOR or None,
    disable_resources=True,
)

print(f"Status: {page.status}")

if CSS_SELECTOR:
    results = page.css(CSS_SELECTOR).getall()
    for r in results:
        print(r)
else:
    print(page.get_all_text(strip=True)[:2000])
