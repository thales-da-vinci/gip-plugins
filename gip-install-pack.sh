#!/bin/bash

echo "🔧 GIP Pack Installer"
read -p "📦 Nome do pack (slug): " PACK

PACK_FILE="packs/$PACK/pack.json"
if [ ! -f "$PACK_FILE" ]; then
  echo "❌ Pack não encontrado: $PACK"
  exit 1
fi

DEST_DIR="../gip-content/modules"
mkdir -p "$DEST_DIR"

echo "📄 Lendo pack $PACK_FILE..."

PLUGINS=$(jq -r '.plugins[] | @base64' "$PACK_FILE")

for plugin in $PLUGINS; do
  _jq() {
    echo $plugin | base64 --decode | jq -r $1
  }

  SLUG=$(_jq '.slug')
  ORIGEM=$(_jq '.origem')

  if [ "$ORIGEM" = "wp-repo" ]; then
    echo "⬇️ Instalando do repositório WP: $SLUG"
    wp plugin install "$SLUG" --activate --path=../ --allow-root
  elif [ "$ORIGEM" = "local" ]; then
    echo "📦 Instalando plugin local: $SLUG"
    if [ -f "plugins/$SLUG" ]; then
      unzip -o "plugins/$SLUG" -d "$DEST_DIR" > /dev/null
    else
      echo "⚠️ Arquivo local não encontrado: plugins/$SLUG"
    fi
  fi
done

echo "✅ Pack instalado!"