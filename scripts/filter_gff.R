library(dplyr)
library(data.table)

#### Functions ####
read_and_filter_gff <- function(gff_path) {
  # Read in the GFF file with specified column names
  gff_data <- data.table::fread(
    gff_path,
    col.names = c(
      "chrom",
      "source",
      "type",
      "start",
      "end",
      "score",
      "strand",
      "phase",
      "attributes"
    )
  )
  
  # Filter to include only mRNA features
  gff_data <- gff_data %>%
    dplyr::filter(type == "mRNA")
  
  return(gff_data)
}

# Example usage
#cb_gff <- read_and_filter_gff(cb_gff_path)
parse_and_filter_transcripts <- function(gff_data, filter_trans) {
  # Create a column for the transcript ID from the attributes column
  gff_data <- gff_data %>%
    dplyr::mutate(
      transcript_id = stringr::str_extract(attributes, "transcript:(.*?);")
    ) %>%
    # Clean up the transcript_id column
    dplyr::mutate(
      transcript_id = stringr::str_replace(transcript_id, "transcript:", ""),
      transcript_id = stringr::str_replace(transcript_id, ";", "")
    )
  
  # Number of rows before filtering
  rows_before <- nrow(gff_data)
  
  # Filter out the specified transcript IDs
  gff_data <- gff_data %>%
    dplyr::filter(!transcript_id %in% filter_trans)
  
  # Number of rows after filtering
  rows_after <- nrow(gff_data)
  
  # Remove the transcript_id column
  gff_data <- gff_data %>%
    dplyr::select(-transcript_id)
  
  # Report the number of transcripts successfully filtered
  filtered_count <- rows_before - rows_after
  message(filtered_count, " transcripts were successfully filtered.")
  
  return(gff_data)
}


# # Example usage
# cb_gff_filtered <- parse_and_filter_transcripts(cb_gff, cb_gene_pred_err)
# ce_gff_filtered <- parse_and_filter_transcripts(ce_gff, cb_gene_pred_err)

write_gff <- function(gff_data, output_path) {
  # Write the GFF data to a file without column names
  data.table::fwrite(gff_data, output_path, col.names = FALSE, sep = "\t")
}

#### Inputs ####
# Read in the GFF file
ce_gff_path <- "c_elegans.PRJNA13758.WS283.csq.gff3.gz"
cb_gff_path <- "c_briggsae.QX1410_nanopore.Feb2020.csq.gff3.gz"
ct_gff_path <- "c_tropicalis.NIC58_nanopore.June2021.csq.gff3.gz"

cb_gene_pred_err <- c(
  "QX1410.13336.2"
)

ct_gene_pred_err <- c(
  "NIC58.15504.2",
  "NIC58.14724.3",
  "NIC58.15977.1",
  "NIC58.18736.4"
)

# Read in the beta-tubulin key file 
# blast_key_file <- "blast_key.tsv"
# blast_key <- data.table::fread(blast_key_file) %>%
#   dplyr::filter(ce_common != "tbb_6")

#### Outputs ####
out_dir <- "filtered_gffs"

# create the output directory if it doesn't exist
# or remove the existing files if they do
if (!dir.exists(out_dir)) {
  dir.create(out_dir)
} else {
  file.remove(list.files(out_dir))
}

#### Main ####

# load gffs and filter to mrna features
ce_gff <- read_and_filter_gff(ce_gff_path)
cb_gff <- read_and_filter_gff(cb_gff_path)
ct_gff <- read_and_filter_gff(ct_gff_path)

# Filter transcripts with gene prediction errors
cb_gff_filtered <- parse_and_filter_transcripts(cb_gff, cb_gene_pred_err)
ct_gff_filtered <- parse_and_filter_transcripts(ct_gff, ct_gene_pred_err)

# Write the filtered GFF files to the output directory

# get the output filename from the input path
# eg c_elegans.PRJNA13758.WS283.csq.gff3.gz -> c_elegans.PRJNA13758.WS283.csq.filtered.gff3
ce_gff_filename <- basename(ce_gff_path)
ce_gff_filename <- stringr::str_replace(ce_gff_filename, ".gff3.gz", ".filtered.gff3")

cb_gff_filename <- basename(cb_gff_path)
cb_gff_filename <- stringr::str_replace(cb_gff_filename, ".gff3.gz", ".filtered.gff3")

ct_gff_filename <- basename(ct_gff_path)
ct_gff_filename <- stringr::str_replace(ct_gff_filename, ".gff3.gz", ".filtered.gff3")

write_gff(ce_gff, file.path(out_dir, ce_gff_filename))
write_gff(cb_gff_filtered, file.path(out_dir, cb_gff_filename))
write_gff(ct_gff_filtered, file.path(out_dir, ct_gff_filename))