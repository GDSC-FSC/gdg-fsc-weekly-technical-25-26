# gemma_ocr documentation!

## Description

DeepSeek OCR but w/ Gemma instead

## Commands

The Makefile contains the central entry points for common tasks related to this project.

### Syncing data to cloud storage

* `make sync_data_up` will use `gsutil rsync` to recursively sync files in `data/` up to `gs://gemmaocr_gdgfsc/data/`.
* `make sync_data_down` will use `gsutil rsync` to recursively sync files in `gs://gemmaocr_gdgfsc/data/` to `data/`.


