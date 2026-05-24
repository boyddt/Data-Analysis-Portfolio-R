# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an R-based data analysis portfolio. The current project (`ExploratoryDataAnalysis/`) performs EDA on NYC 311 Service Requests data (2020–present), producing borough-level visualizations including a choropleth map.

## Running / Rendering

**Run the R script interactively (RStudio or terminal):**
```bash
Rscript "EDA Project.R"
```

**Render the Quarto report to HTML:**
```bash
quarto render "EDA Project 1.qmd"
```

The `.Rproj` file uses 2-space indentation and UTF-8 encoding.

## Architecture

There are two parallel analysis files for the same analysis:

- `EDA Project.R` — exploratory scratchpad; code is developed and tested here first
- `EDA Project 1.qmd` — Quarto document that contains the polished, narrative version of the same analysis with prose explanations between code chunks

**Data pipeline:**
1. Load raw CSV via `data.table::fread()` (large file: `311_Service_Requests_from_2020_to_Present_20260509.csv`)
2. Standardize column names with `janitor::clean_names()`
3. Type-cast: ID fields (`unique_key`, `bbl`) → `character`; date fields → `POSIXct` via `lubridate::mdy_hms()`
4. Profile missingness with `colMeans(is.na(df))`
5. Visualize with `ggplot2` — bar chart of calls by borough, then a choropleth using `tigris::counties()` spatial data joined to aggregated counts

**Key packages:** `data.table`, `dplyr`, `lubridate`, `ggplot2`, `scales`, `janitor`, `tigris`, `socratadata`

**Intermediate output files** (written during analysis, not source files):
- `311_Sample.csv`, `311_Sample_50.csv` — random samples of the raw data
- `borough_counts.csv`, `nyc_boroughs.csv` — aggregated/spatial data for the choropleth
- `Borough_311_Calls.png` — exported map

## GitHub Workflow

Use the `gh` CLI for issue-driven development:

```bash
gh issue list                        # see open issues
gh issue view <number>               # read issue details
gh issue develop <number>            # create a linked branch for the issue
git checkout <branch-name>           # switch to that branch before making changes
```

Work is done on the issue branch, then merged via PR:

```bash
gh pr create                         # open a PR from the current branch
gh pr view                           # check PR status
```

## Data Source

`311_Service_Requests_from_2020_to_Present_20260509.csv` — downloaded from NYC Open Data. The `socratadata` package is loaded but data is read from local CSV, not the API.
