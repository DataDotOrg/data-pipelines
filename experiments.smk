configfile: "config.yaml"

# rule all:
#     # eventually, input should consist of the ultimate target so snakemake can resolve how to build it
#     input:
#         "data/linelist_example_data_filtered_cols.csv",
#         "data/epinow2_reported_cases.transformed.csv",
#         "results/epinow2_reported_cases.epiestim_estimate_r.csv",
#         "logs/epinow2_reported_cases.epiestim_estimate_r.log",
#         "results/linelist_example_data_filtered_cols.incidence.csv",
#         "logs/linelist_example_data_filtered_cols.incidence.log",
#         "viz/dag.png"










# rule epiestim_incidence:
#     input:
#         data="data/incidence_data.transformed.csv"
#     output:
#         data="results/epinow2_incidence_data.csv"
#     params:
#         mean=config["covid"]["mean"],
#         std=config["covid"]["std"],
#         plot="viz/covid_R_estimates.png"
#     log:
#         data="logs/epinow2_incidence_data.log"
#     shell:
#         "Rscript tools/epiestim_estimate_r_parametric.R -i {input.data} -o {output.data} --mean {params.mean}"
#         " --std {params.std} --plot {params.plot} --log {log.data}"



