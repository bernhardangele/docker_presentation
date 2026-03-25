# Docker Presentation

Materials for the "Analysis in a Box" presentation on using Docker for reproducible R analyses.

## Quick Start

### 1. Run the Docker container

```bash
docker run -e PASSWORD=yourpassword -p 8787:8787 \
  -v $(pwd):/home/rstudio \
  bangele1/analysis-in-a-box-rocker:latest
```

Then open [http://127.0.0.1:8787](http://127.0.0.1:8787) in your browser.

- **Username:** `rstudio`
- **Password:** `yourpassword` (whatever you set above)

### 2. Open the RStudio project

In RStudio, go to **File > Open Project** and select `docker_presentation.Rproj`, or open it from the Files pane.

### 3. Get the model files

The presentation requires pre-computed BRMS model files (`.qs2`). You have two options:

**Option A — Download from OSF (recommended):**

```r
source("analysis/download_models.R")
```

This will download the cached model files from OSF if they are not already present.

**Option B — Run the full analysis:**

Open `analysis/analysis_exp2.R` in RStudio and run it. This fits the BRMS models from scratch and saves the results as `.qs2` files. This requires CmdStanR and can take a long time.

> In both cases, the `.qs2` files must exist in `analysis/` before building the presentation.

### 4. Build the presentation

In the RStudio **Terminal** tab, run:

```bash
quarto render presentation/presentation.qmd
```

The output will be saved to `presentation/presentation.html`.

## Using GitHub Codespaces

No local Docker installation needed. GitHub Codespaces runs the container in the cloud and gives you a full VS Code environment in your browser.

1. Click the green **<> Code** button at the top of this repository
2. Select the **Codespaces** tab
3. Click **Create codespace on main**
4. Wait for the container to build (may take a few minutes)
5. Once ready, go to the **Ports** tab at the bottom of the screen and click the **Open in Browser** icon next to port **8787** to open RStudio
6. Log in to RStudio (**Username:** `rstudio`, **Password:** set in the container environment)
7. In RStudio, go to **File > Open Project** and select `docker_presentation.Rproj`
8. In the RStudio **Console**, run:

```r
source("analysis/download_models.R")
```

Alternatively, you can open `download_models.R` in RStudio and click `Source`.

> **Do not try to run `analysis_exp2.R` in the codespace** — fitting the BRMS models can take hours. Use the download script instead.

9. In the RStudio **Terminal**, build the presentation:

```bash
quarto render presentation/presentation.qmd
```

Alternatively, you can open `presentation.qmd` in RStudio and click `Render`

The rendered presentation will be in `presentation/presentation.html`.

### Alternative: Terminal only (no RStudio)

If you prefer not to use RStudio, you can run everything from the VS Code terminal:

```bash
Rscript analysis/download_models.R
quarto render presentation/presentation.qmd
```

> **Tip:** Codespaces gives you the same pre-configured R environment as the local Docker container — with RStudio, brms, Quarto, and all dependencies ready to go.

## Using Docker Compose

Alternatively, create a `docker-compose.yml` in the project root:

```yaml
services:
  analysis-in-a-box:
    image: bangele1/analysis-in-a-box-rocker:latest
    environment:
      - PASSWORD=yourpassword
    ports:
      - "8787:8787"
    volumes:
      - .:/home/rstudio
```

Then run:

```bash
docker compose up -d    # Start container
docker compose down     # Stop container
```

## Project Structure

```
docker_presentation/
├── analysis/
│   ├── analysis_exp2.R          # BRMS analysis script
│   ├── download_models.R        # Downloads cached models from OSF
│   ├── blmm_exp2_rt_dist.qs     # Cached RT model
│   └── blmm_acc_exp2.qs         # Cached accuracy model
├── data/                        # Raw participant CSV files
├── presentation/
│   ├── presentation.qmd         # Quarto source
│   ├── presentation.html        # Rendered slides
│   ├── styles.css               # Custom CSS
│   ├── apa.csl                  # APA7 citation style
│   └── references.bib           # Bibliography
└── README.md
```

## Notes

- BRMS models are pre-computed and saved as `.qs2` files via `analysis_exp2.R`. The presentation loads these cached models rather than re-running MCMC.
- To re-run the full analysis, open `analysis/analysis_exp2.R` in RStudio and execute it (requires CmdStanR).
