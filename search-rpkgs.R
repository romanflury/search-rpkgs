# this script searches all files -in the current workingdirectory-, -for the specified suffixes-
# for used rpackages and installs them
# feel free to set the .libPaths() of your choice

rm(list = ls())
library(stringr)

SUFFIX <- c("(.*).Rnw", "(.*).R$")
RP_IDENTIFIER <- c("library", "require", "::")
REGEX <- c("library\\(([a-z|A-Z|0-9|\\_|\\-|\"|\'|\\s]*)\\)",
           "require\\(([a-z|A-Z|0-9|\\_|\\-|\"|\'|\\s]*)\\)",
           "([a-z|A-Z|0-9|\\_|\\-]*)::")
OBSOLETECHARS <- c("\"", "\'", " ")

# find files ---------------------------------------------------------------------- #
files <- c()
for (s in SUFFIX) {
  files <-  c(files, list.files(pattern     = s,
                                recursive   = TRUE,
                                ignore.case = FALSE,
                                full.names  = FALSE)) }

if (length(which(files == "installpackages.R")) > 0) {
  files <- files[-which(files == "installpackages.R")]
}

# search files for pkgs ----------------------------------------------------------- #
pkgs <- c()
for (i in 1:length(files)) {
  tmpfile <- readLines(files[i])

  for (identifier in RP_IDENTIFIER) {
    pkgs <- c(pkgs, grep(identifier, tmpfile, value = TRUE))
  }
}

# cleanup for pkg names ----------------------------------------------------------- #
pkgs <- unique(pkgs)

# match regular expressions
match <- c()
for (regex in REGEX) {
  match <- c(match, stringr::str_match(pkgs, regex)[ ,2])
}
match <- unique(match[!is.na(match)])

# rm OBSOLETECHARS
for (char in OBSOLETECHARS) {
  match <- gsub(char, "", match)
}
match <- unique(match[!is.na(match)])

# install packages ---------------------------------------------------------------- #
install.packages(match, lib = "lib/", dependencies = TRUE)

