#!/usr/bin/env python3
"""Deterministic health check for The Land of Roo. Uses no AI model calls."""

from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from pathlib import Path


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.title_parts: list[str] = []
        self.in_title = False
        self.descriptions: list[str] = []
        self.canonicals: list[str] = []
        self.h1_count = 0
        self.links: list[str] = []
        self.images: list[dict[str, str | None]] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = dict(attrs)
        if tag == "title":
            self.in_title = True
        elif tag == "meta" and (data.get("name") or "").lower() == "description":
            if data.get("content"):
                self.descriptions.append(data["content"] or "")
        elif tag == "link" and (data.get("rel") or "").lower() == "canonical":
            if data.get("href"):
                self.canonicals.append(data["href"] or "")
        elif tag == "h1":
            self.h1_count += 1
        elif tag == "a" and data.get("href"):
            self.links.append(data["href"] or "")
        elif tag == "img" and data.get("src"):
            self.images.append({"src": data["src"], "alt": data.get("alt")})

    def handle_endtag(self, tag: str) -> None:
        if tag == "title":
            self.in_title = False

    def handle_data(self, data: str) -> None:
        if self.in_title:
            self.title_parts.append(data)


def fetch(url: str, timeout: int = 15) -> tuple[int, str, str]:
    request = urllib.request.Request(url, headers={"User-Agent": "RooWebmasterHealth/1.0"})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = response.read().decode("utf-8", errors="replace")
            return response.status, response.headers.get("Content-Type", ""), body
    except urllib.error.HTTPError as exc:
        return exc.code, exc.headers.get("Content-Type", ""), ""
    except Exception as exc:
        return 0, "", f"{type(exc).__name__}: {exc}"


def normalize(base_url: str, page_url: str, target: str) -> str | None:
    if not target or target.startswith(("#", "mailto:", "tel:", "javascript:")):
        return None
    absolute = urllib.parse.urljoin(page_url, target)
    parsed = urllib.parse.urlsplit(absolute)
    base = urllib.parse.urlsplit(base_url)
    if parsed.scheme not in ("http", "https") or parsed.netloc != base.netloc:
        return None
    return urllib.parse.urlunsplit((parsed.scheme, parsed.netloc, parsed.path or "/", parsed.query, ""))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="https://thelandofroo.com")
    parser.add_argument("--output", default="reports/health-latest.json")
    parser.add_argument("--source-dir", help="Check a local static-site directory instead of the live site")
    args = parser.parse_args()
    base_url = args.base_url.rstrip("/")
    source_dir = Path(args.source_dir).resolve() if args.source_dir else None
    started = time.time()

    def retrieve(url: str) -> tuple[int, str, str]:
        if source_dir:
            parsed = urllib.parse.urlsplit(url)
            base = urllib.parse.urlsplit(base_url)
            if parsed.netloc != base.netloc:
                return 0, "", "external URL"
            relative = urllib.parse.unquote(parsed.path).lstrip("/")
            if not relative or parsed.path.endswith("/"):
                relative = f"{relative}index.html"
            candidate = (source_dir / relative).resolve()
            if not candidate.is_relative_to(source_dir):
                return 0, "", "path outside source directory"
            if not candidate.is_file():
                return 404, "", ""
            content_type = "text/html" if candidate.suffix.lower() in (".html", ".htm") else "application/octet-stream"
            return 200, content_type, candidate.read_text(encoding="utf-8", errors="replace")
        return fetch(url)

    sitemap_url = f"{base_url}/sitemap.xml"
    sitemap_status, _, sitemap_body = retrieve(sitemap_url)
    pages: list[str] = []
    errors: list[dict[str, object]] = []
    if sitemap_status == 200:
        try:
            root = ET.fromstring(sitemap_body)
            pages = [node.text.strip() for node in root.findall("{*}url/{*}loc") if node.text]
        except ET.ParseError as exc:
            errors.append({"url": sitemap_url, "problem": f"invalid sitemap: {exc}"})
    else:
        errors.append({"url": sitemap_url, "status": sitemap_status, "problem": "sitemap unavailable"})

    checked_resources: dict[str, int] = {}
    page_results: list[dict[str, object]] = []
    for page_url in pages:
        status, content_type, body = retrieve(page_url)
        result: dict[str, object] = {"url": page_url, "status": status, "issues": []}
        issues: list[str] = result["issues"]  # type: ignore[assignment]
        if status != 200:
            issues.append(f"HTTP {status or 'network error'}")
        elif "text/html" not in content_type.lower():
            issues.append(f"unexpected content type: {content_type}")
        else:
            html = PageParser()
            html.feed(body)
            if not "".join(html.title_parts).strip():
                issues.append("missing title")
            if len(html.descriptions) != 1:
                issues.append(f"expected one meta description, found {len(html.descriptions)}")
            if len(html.canonicals) != 1:
                issues.append(f"expected one canonical URL, found {len(html.canonicals)}")
            if html.h1_count != 1:
                issues.append(f"expected one H1, found {html.h1_count}")
            for image in html.images:
                if image["alt"] is None:
                    issues.append(f"image missing alt attribute: {image['src']}")
            resources = html.links + [str(image["src"]) for image in html.images]
            for target in resources:
                url = normalize(base_url, page_url, target)
                if url and url not in checked_resources:
                    checked_resources[url] = retrieve(url)[0]
            broken = [url for url in (normalize(base_url, page_url, item) for item in resources)
                      if url and checked_resources.get(url) != 200]
            if broken:
                issues.append(f"broken internal resources: {', '.join(sorted(set(broken)))}")
        page_results.append(result)
        for issue in issues:
            errors.append({"url": page_url, "problem": issue})

    report = {
        "status": "PASS" if pages and not errors else "FAIL",
        "base_url": base_url,
        "mode": "local" if source_dir else "production",
        "sitemap_status": sitemap_status,
        "pages_checked": len(page_results),
        "unique_internal_resources_checked": len(checked_resources),
        "duration_seconds": round(time.time() - started, 2),
        "ai_model_calls": 0,
        "errors": errors,
        "pages": page_results,
    }
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps({key: report[key] for key in (
        "status", "pages_checked", "unique_internal_resources_checked", "duration_seconds", "ai_model_calls"
    )}, ensure_ascii=False))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
