
install_missing_packages <- function(list_of_packages) {
    # check if the packages are installed
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

    # if not, install them
    if (length(new.packages)) install.packages(new.packages, repos="https://cloud.r-project.org/", dependencies=TRUE)
}

