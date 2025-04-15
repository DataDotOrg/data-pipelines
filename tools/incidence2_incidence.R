list.of.packages <- c("incidence2")

source("tools/install_packages.R")

install_missing_packages()

# Example of using the incidence2 package to convert linelist data to count data


# option list
option_list <- list(
    optparse::make_option(c("-i", "--input"), type = "character", default = NULL, help = "Input file path", metavar = "input"),
    optparse::make_option(c("-o", "--output"), type = "character", default = NULL, help = "Output file path", metavar = "output"),
    optparse::make_option("--date_index_name", type = "character", default = "date_index", help = "The name of the column with the date to use", metavar = "date index"),
    optparse::make_option("--plot", type = "character", help = "Output plot file path", metavar = "plot"),
    optparse::make_option("--sleep_time", type = "integer", default = 10, help = "If plot interactive, sleep for this many seconds [default: 10s]"),
    optparse::make_option("--log", type = "character", help = "Log file path", metavar = "log")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = option_list))

# if a log file is specified use it
if (!is.null(opt$log)) {
    sink(opt$log, append = TRUE, type = "output")
    # sink(opt$log, append = TRUE, type = "message")
}

aggregate_linelist <- function(opt) {

    data <- read.csv(opt$input)
    head(data)
    aggregated_data <- incidence2::incidence(data, date_index = opt$date_index_name)
    write.csv(aggregated_data, opt$output, row.names = FALSE)
}

# load the file
if (file.exists(opt$input)) {
    aggregate_linelist(opt)
} else {
    stop("File does not exist.")
}


