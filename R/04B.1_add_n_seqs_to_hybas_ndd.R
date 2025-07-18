add_n_seqs_to_hybas_nnd <- function(hybas_nnd,
                                    refdb = paste0(out_path, "refdb_", db_name, ".fasta")) {
  # read in reference database
  if (grepl(refdb[1], pattern = "fasta")) {
    r <- readDNAStringSet(refdb)
  } else{
    r <- refdb
  }
  
  # get df of reference database
  rn_n_seq <- RDP_to_dataframe(r) %>%
    group_by(o, s) %>%
    summarize(n_seqs = length(s), .groups = "drop") %>%
    ungroup() %>%
    dplyr::mutate(seq_species = ununderscore(s)) %>%
    dplyr::select(seq_species, n_seqs)
  
  hybas_nnd_n_seqs <- lapply(hybas_nnd, function(x) {
    if (sum(grepl(names(x), pattern = "seq_species")) %in% 0) {
      x <- x %>% mutate(seq_species = NA)
    }
    
    df <- x %>%
      left_join(rn_n_seq, by = join_by(seq_species)) %>%
      tidyr::replace_na(list(n_seqs = 0))
    
    return(df)
  })
  
  return(hybas_nnd_n_seqs)
  
}