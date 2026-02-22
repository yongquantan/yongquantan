#!/usr/bin/env bash
set -euo pipefail

echo "Building site..."
mkdocs build

echo "Deploying to Vercel..."
vercel deploy --prod

echo "Pinging Google sitemap..."
curl -s "https://www.google.com/ping?sitemap=https://yongquantan.com/sitemap.xml"

echo ""
echo "Done! Site deployed and Google notified."
