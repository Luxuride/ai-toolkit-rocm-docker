#!/bin/bash
set -e

for dir in models datasets output checkpoints config; do
    target="/opt/ai-toolkit/${dir}"
    source="/opt/ai-toolkit_defaults/${dir}"
    if [ -d "$source" ] && [ -d "$target" ] && [ -w "$target" ]; then
        if [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
            cp -a "$source"/. "$target"/ 2>/dev/null || true
        else
            for subdir in "$source"/*/; do
                subdir_name="$(basename "$subdir")"
                if [ ! -e "$target/$subdir_name" ]; then
                    cp -a "$subdir" "$target"/ 2>/dev/null || true
                fi
            done
        fi
    fi
done

# Move aitk_db.db to /opt/ai-toolkit/db/ and create soft link
db_target="/opt/ai-toolkit/db/aitk_db.db"
db_link="/opt/ai-toolkit/aitk_db.db"
db_defaults="/opt/ai-toolkit_defaults/aitk_db.db"

# Create db directory if it doesn't exist
mkdir -p "/opt/ai-toolkit/db"

# If defaults db exists and target doesn't, copy it
if [ -f "$db_defaults" ] && [ ! -f "$db_target" ]; then
    cp -a "$db_defaults" "$db_target" 2>/dev/null || true
fi

# If db exists in the mount (old location), move it to new location
if [ -f "$db_link" ] && [ ! -f "$db_target" ]; then
    mv "$db_link" "$db_target" 2>/dev/null || true
fi

# Remove old db file if it exists and create soft link
if [ -f "$db_link" ] || [ -L "$db_link" ]; then
    rm -f "$db_link" 2>/dev/null || true
fi

# Create soft link from /opt/ai-toolkit/aitk_db.db -> /opt/ai-toolkit/db/aitk_db.db
ln -sf "$db_target" "$db_link"

# Ensure HuggingFace cache directory structure exists
hf_cache="/root/.cache/huggingface"
mkdir -p "$hf_cache/hub" "$hf_cache/xet"

# Copy HF cache defaults if available
hf_source="/root/.cache_defaults/huggingface"
if [ -d "$hf_source" ]; then
    for subdir in "$hf_source"/*/; do
        subdir_name="$(basename "$subdir")"
        if [ ! -e "$hf_cache/$subdir_name" ]; then
            cp -a "$subdir" "$hf_cache"/ 2>/dev/null || true
        fi
    done
fi
