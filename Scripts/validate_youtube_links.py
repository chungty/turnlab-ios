#!/usr/bin/env python3
"""
YouTube Link Validator for Turn Lab App

Validates all YouTube video IDs in the skills content and reports any invalid links.
Uses YouTube's oEmbed API (no API key required).

Usage:
    python Scripts/validate_youtube_links.py

Exit codes:
    0 - All links valid
    1 - Some links invalid
"""

import asyncio
import aiohttp
import json
import re
import sys
from pathlib import Path
from typing import Optional


async def check_youtube_link(
    session: aiohttp.ClientSession,
    video_id: str,
    title: str
) -> dict:
    """Check if a YouTube video ID is valid and accessible."""
    if not video_id or len(video_id) != 11:
        return {
            "video_id": video_id,
            "title": title,
            "valid": False,
            "error": "Invalid video ID format (must be 11 characters)"
        }

    # Use oEmbed endpoint (no API key needed)
    oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"

    try:
        async with session.get(oembed_url, timeout=aiohttp.ClientTimeout(total=10)) as response:
            if response.status == 200:
                data = await response.json()
                return {
                    "video_id": video_id,
                    "title": title,
                    "valid": True,
                    "youtube_title": data.get("title"),
                    "author": data.get("author_name"),
                    "url": f"https://www.youtube.com/watch?v={video_id}"
                }
            elif response.status == 401:
                return {
                    "video_id": video_id,
                    "title": title,
                    "valid": False,
                    "error": "Video is private or embedding disabled"
                }
            elif response.status == 404:
                return {
                    "video_id": video_id,
                    "title": title,
                    "valid": False,
                    "error": "Video not found (deleted or invalid ID)"
                }
            else:
                return {
                    "video_id": video_id,
                    "title": title,
                    "valid": False,
                    "error": f"HTTP {response.status}"
                }
    except asyncio.TimeoutError:
        return {
            "video_id": video_id,
            "title": title,
            "valid": False,
            "error": "Request timeout"
        }
    except Exception as e:
        return {
            "video_id": video_id,
            "title": title,
            "valid": False,
            "error": str(e)
        }


def extract_video_id(url: str) -> Optional[str]:
    """Extract video ID from various YouTube URL formats."""
    if not url:
        return None

    patterns = [
        r'(?:youtube\.com/watch\?v=|youtu\.be/)([^&\n?#]+)',
        r'youtube\.com/embed/([^&\n?#]+)',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)

    # If it looks like a bare video ID (11 chars alphanumeric with - and _)
    if re.match(r'^[A-Za-z0-9_-]{11}$', url):
        return url

    return None


async def validate_videos_json(file_path: Path) -> dict:
    """Load and validate all videos from videos.json."""

    if not file_path.exists():
        print(f"Error: {file_path} not found")
        return {"valid": [], "invalid": [], "error": "File not found"}

    with open(file_path) as f:
        data = json.load(f)

    videos = data.get("videos", [])

    if not videos:
        print("No videos found in file")
        return {"valid": [], "invalid": [], "error": "No videos in file"}

    print(f"Validating {len(videos)} YouTube videos...\n")

    async with aiohttp.ClientSession(
        headers={"User-Agent": "Mozilla/5.0 (compatible; TurnLabValidator/1.0)"}
    ) as session:
        tasks = [
            check_youtube_link(session, v.get("youtubeId", ""), v.get("title", "Unknown"))
            for v in videos
        ]
        results = await asyncio.gather(*tasks)

    valid = [r for r in results if r["valid"]]
    invalid = [r for r in results if not r["valid"]]

    return {"valid": valid, "invalid": invalid}


def print_results(results: dict) -> int:
    """Print validation results and return exit code."""
    valid = results.get("valid", [])
    invalid = results.get("invalid", [])
    total = len(valid) + len(invalid)

    if not total:
        print("No videos to validate")
        return 0

    print("=" * 60)
    print("VALIDATION RESULTS")
    print("=" * 60)

    if valid:
        print(f"\n{len(valid)} VALID videos:")
        for v in valid:
            print(f"  {v['video_id']}: {v.get('youtube_title', v['title'])}")
            if v.get('author'):
                print(f"              by {v['author']}")

    if invalid:
        print(f"\n{len(invalid)} INVALID videos:")
        for v in invalid:
            print(f"  {v['video_id']}: {v['title']}")
            print(f"              Error: {v['error']}")

    print("\n" + "=" * 60)
    print(f"SUMMARY: {len(valid)}/{total} videos valid")

    if invalid:
        print(f"\nWARNING: {len(invalid)} videos need replacement!")
        print("\nRecommended actions:")
        print("  1. Find replacement videos from Stomp It Tutorials or Ski School by Elate Media")
        print("  2. Update TurnLab/Resources/Content/videos.json with valid YouTube IDs")
        print("  3. Re-run this script to verify")

    print("=" * 60)

    return 0 if not invalid else 1


async def main():
    # Find videos.json relative to script location or project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    videos_file = project_root / "TurnLab" / "Resources" / "Content" / "videos.json"

    if not videos_file.exists():
        # Try current working directory
        videos_file = Path("TurnLab/Resources/Content/videos.json")

    results = await validate_videos_json(videos_file)
    exit_code = print_results(results)

    # Output JSON for programmatic access
    output_file = project_root / "Scripts" / "validation_results.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nDetailed results saved to: {output_file}")

    return exit_code


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
