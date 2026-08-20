# ai-toolkit-ROCm-Docker

Docker image for [ostris/ai-toolkit](https://github.com/ostris/ai-toolkit) with AMD ROCm GPU acceleration, based on the official [rocm/pytorch](https://hub.docker.com/r/rocm/pytorch) image. Built with the latest daily version of ai-toolkit.

## Usage

```bash
docker run --rm -it \
  --device /dev/kfd --device /dev/dri \
  --security-opt seccomp=unconfined \
  --security-opt label=disable \
  -p 8675:8675 \
  -v $(pwd)/models:/opt/ai-toolkit/models \
  -v $(pwd)/datasets:/opt/ai-toolkit/datasets \
  -v $(pwd)/output:/opt/ai-toolkit/output \
  -v $(pwd)/checkpoints:/opt/ai-toolkit/checkpoints \
  -v $(pwd)/db:/opt/ai-toolkit/db \
  -v $(pwd)/.cache:/root/.cache \
  ghcr.io/luxuride/ai-toolkit-rocm-docker:latest
```

```yaml
services:
  ai-toolkit:
    image: ghcr.io/luxuride/ai-toolkit-rocm-docker:latest
    container_name: ai-toolkit-rocm
    devices:
      - /dev/kfd:/dev/kfd
      - /dev/dri:/dev/dri
    security_opt:
      - seccomp=unconfined
      - label=disable
    ports:
      - 8675:8675
    volumes:
      - ./models:/opt/ai-toolkit/models
      - ./datasets:/opt/ai-toolkit/datasets
      - ./output:/opt/ai-toolkit/output
      - ./checkpoints:/opt/ai-toolkit/checkpoints
      - ./db:/opt/ai-toolkit/db
      - ./.cache:/root/.cache
    restart: unless-stopped
```

> **Warning:** Do **not** use the `:z` or `:Z` SELinux volume relabeling flags (e.g., `-v $(pwd)/models:/opt/ai-toolkit/models:z`). Relabeling changes file ownership/labels inside the container and will cause ai-toolkit to crash during training.

## Volumes

| Path | Purpose |
|---|---|
| `models/` | Pre-trained model files |
| `datasets/` | Training datasets |
| `output/` | Training outputs and logs |
| `checkpoints/` | Training checkpoints |
| `db/` | Directory containing `aitk_db.db` — SQLite database (training queue, jobs, settings). The file is stored at `/opt/ai-toolkit/db/aitk_db.db` with a soft link at `/opt/ai-toolkit/aitk_db.db` for compatibility. |
| `.cache/huggingface/` | HuggingFace model cache (downloaded models) |

## Tags

This image is built daily with a `YYYY-MM-DD` tag format (e.g., `2025-06-18`). Use the latest tag for the most recent ai-toolkit version, or pin to a specific date for reproducibility.

## Automated Builds

A daily GitHub Action builds the image with the latest ai-toolkit source code and tags it with the current date in `YYYY-MM-DD` format.