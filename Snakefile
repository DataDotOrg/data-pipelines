configfile: "config.yaml"

rule all:
    input:
        # influenza
        "data/linelist_example_data_filtered_cols.csv",
        "logs/epinow2_reported_cases.validation.log",
        # ebola
        "data/ebola_incidence.transformed.csv",
        "results/ebola_estimate_r.csv",
        "viz/dag.png"


# -----------------------------------------
# epinow2 data transformation for epiestim
# -----------------------------------------

rule transform_by_schema:
    input:
        data="data/epinow2_reported_cases.csv"
    output:
        data="data/epinow2_reported_cases.transformed.csv"
    params:
        schema="schemas/epiestim_estimate_r.input.schema.yaml"
    shell:
        "python tools/transform_by_schema.py --schema {params.schema} {input.data} --output {output.data}"


rule epiestim_estimate_r:
    input:
        data="data/epinow2_reported_cases.transformed.csv"
    output:
        data="results/epinow2_reported_cases.epiestim_estimate_r.csv"
    params:
        mean=config["influenza"]["mean"],
        std=config["influenza"]["std"],
        plot="viz/influenza_R_estimates.png"
    log:
        data="logs/epinow2_reported_cases.epiestim_estimate_r.log"
    shell:
        "Rscript tools/epiestim_estimate_r_parametric.R -i {input.data} -o {output.data} --mean {params.mean}"
        " --std {params.std} --plot {params.plot} --log {log.data}"

rule validate_epiestim_estimate_r_output:
    input:
        data="results/epinow2_reported_cases.epiestim_estimate_r.csv"
    log:
        data="logs/epinow2_reported_cases.validation.log"
    params:
        schema="schemas/epiestim_estimate_r.output.schema.yaml"
    shell:
        "frictionless validate {input.data} --schema {params.schema} --yaml > {log.data}"

# -----------------------------------------
# linelist data transformation for epiestim (not fully functional)
# -----------------------------------------

rule incidence2:
    input:
        data="data/ebola_linelist.csv"
    output:
        data="data/ebola_incidence.csv"
    params:
        date_index_name="date_of_onset"
    shell:
        "Rscript tools/incidence2_incidence.R --input {input.data} --output {output.data} --date_index_name {params.date_index_name}"


rule validate_incidence2_output:
    input:
        data="data/ebola_incidence.csv"
    output:
        data="logs/ebola_incidence.log"
    params:
        schema="schemas/incidence2_incidence.output.schema.yaml"
    shell:
        "frictionless validate {input.data} --schema {params.schema} --yaml > {output.data}"


rule incidence_field_remove:
    input:
        data="data/ebola_incidence.csv"
    output:
        data="data/ebola_incidence.field_removed.csv"
    params:
        pipeline="transforms/incidence_to_epiestim.yaml"
    shell:
        "frictionless transform --pipeline {params.pipeline} {input.data}"


rule incidence_transform_to_epiestim:
    input:
        data="data/ebola_incidence.field_removed.csv"
    output:
        data="data/ebola_incidence.transformed.csv"
    params:
        schema="schemas/epiestim_estimate_r.input.schema.yaml"
    shell:
        "python tools/transform_by_schema.py --schema {params.schema} {input.data} --output {output.data}"


rule validate_incidence2_epiestim_format:
    input:
        data="data/ebola_incidence.transformed.csv"
    output:
        data="logs/ebola_incidence.transformed.log"
    params:
        schema="schemas/epiestim_estimate_r.input.schema.yaml"
    shell:
        "frictionless validate {input.data} --schema {params.schema} --yaml > {output.data}"

rule epiestim_incidence:
    input:
        data="data/ebola_incidence.transformed.csv"
    output:
        data="results/ebola_estimate_r.csv"
    params:
        mean=config["ebola"]["mean"],
        std=config["ebola"]["std"],
        plot="viz/ebola_R_estimates.png"
    log:
        data="logs/ebola_estimate_r.log"
    shell:
        "Rscript tools/epiestim_estimate_r_parametric.R -i {input.data} -o {output.data} --mean {params.mean}"
        " --std {params.std} --plot {params.plot} --log {log.data}"

rule draw_dag:
    input:
        "Snakefile"
    output:
        "viz/dag.png"
    shell:
        "snakemake --dag dot | dot -Tpng > {output}"