library(here)

# Define local file names and their corresponding direct OSF download URLs.
files_to_download <- c(
  "blmm_acc_exp2.qs" = "https://osf.io/download/5w7ck/",
  "blmm_exp2_rt_dist.qs" = "https://osf.io/download/b8ksh/"
)

# Loop through each item in the list
for (file_path in names(files_to_download)) {

  dest <- here("analysis", file_path)
  osf_url <- files_to_download[[file_path]]

  # Check if the file already exists
  if (!file.exists(dest)) {
    message(sprintf("'%s' not found locally. Downloading...", file_path))

    tryCatch({
      download.file(osf_url, destfile = dest, mode = "wb", quiet = TRUE)
      message(sprintf(" -> Download of '%s' complete!", file_path))
    }, error = function(e) {
      message(sprintf(" -> Failed to download '%s'. Please check the connection or URL.", file_path))
    })

  } else {
    message(sprintf("'%s' found locally. Skipping download.", file_path))
  }
}
