# list the required packages
list.of.packages <- c("optparse", "EpiEstim", "ggplot2", "incidence")

source("tools/install_packages.R")

install_missing_packages()

# Example of using the EpiEstim package to estimate the effective reproduction number R parametrically
library(ggplot2)
library(incidence)

# option list
option_list <- list(
    optparse::make_option(c("-i", "--input"), type = "character", default = NULL, help = "Input file path", metavar = "input"),
    optparse::make_option(c("-o", "--output"), type = "character", default = NULL, help = "Output file path", metavar = "output"),
    optparse::make_option("--mean", type = "numeric", default = 2.6, help = "Mean of the serial interval", metavar = "mean"),
    optparse::make_option("--std", type = "numeric", default = 1.5, help = "Standard deviation of the serial interval", metavar = "standard deviation"),
    optparse::make_option("--plot", type = "character", help = "Output plot file path", metavar = "plot"),
    optparse::make_option("--sleep_time", type="integer", default = 10, help = "If plot interactive, sleep for this many seconds [default: 10s]"),
    optparse::make_option("--log", type = "character", help = "Log file path", metavar = "log")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = option_list))

# if a log file is specified use it
if (!is.null(opt$log)) {
    sink(opt$log, append = TRUE, type = "output")
    # sink(opt$log, append = TRUE, type = "message")
}

# function to do the analysis
parametric_estimation_of_R <- function(opt) {
    # notify the user
    print(cat("Carrying out analysis using file '", opt$input, "'..."))
    data <- read.csv(opt$input, colClasses = c("Date", "numeric"))
    res_parametric_si <- EpiEstim::estimate_R(
        data,
        method = "parametric_si",
        config = EpiEstim::make_config(list(
            mean_si = opt$mean,
            std_si = opt$std))
    )
    if (!is.null(opt$plot)) {
        png(opt$plot, width=1000, height=1000, res=100)
        plot(res_parametric_si, legend = FALSE)
        dev.off()
    } else {
        # display the plot in a window; system-dependent
        switch(
            Sys.info()[["sysname"]],
            "Darwin" = quartz(),
            "Linux" = x11(),
            "Windows" = windows()
        )
        plot(res_parametric_si, legend = FALSE)
        Sys.sleep(opt$sleep_time) # wait for the plot to be displayed
    }
    write.csv(res_parametric_si$R, opt$output, row.names = FALSE)
}


# load the file
if (file.exists(opt$input)) {
    parametric_estimation_of_R(opt)
} else {
    stop("File does not exist.")
}


