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

### 3. Run the analysis

Open `analysis/analysis_exp2.R` in RStudio and run it. This fits the BRMS models and saves the results as `.qs2` files. **This must be done before building the presentation**, as the presentation loads these cached model files.

> **Note:** This step requires CmdStanR and can take a long time to complete.
> Alternatively, the files can be downloaded from [https://osf.io/avbh5/]

### 4. Build the presentation

In the RStudio **Terminal** tab, run:

```bash
quarto render presentation/presentation.qmd
```

The output will be saved to `presentation/presentation.html`.

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
