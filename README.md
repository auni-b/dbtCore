# Evaluation of dbt

## Design and Usage

This project involved implementing a local pipeline for 20 years of SPY index data, ingesting, modeling, and validating the time-series data in a local environment using dbt Core and DuckDB.

The index data is ingested via a python script, which can be found in `get_spy_data.py`. Afterwards, the resulting csv in `dbt_project/seeds` can be seeded using `dbt seed`, and subsequent runs of the models with `dbt run`, the tests with `dbt test`, and debugging with `dbt debug`, all yield the expected results. The models and tests are located in `dbt_project/models`.

CSVs of the results of these runs are included at the top folder here as `staged_spy_data.csv`, `transformed_spy_data.csv`, and `validation_metrics.csv`. The second of these shows the transformed dataset ready for downstream use, while the last contains the topline validation metrics.

## Experience and Comparison

### Reflections on Developer Experience

The learning curve for using dbt Core felt tough initially. Admittedly, that had much to do with this being the first time I was properly working with a data transformation framework - I've preprocessed datasets and directly interfaced with them via python/SQL files previously instead of actually pipelining them as was the case here.

I ran into some difficulties trying to get dbt Core and DuckDB installed on my system. To begin, I tried using a virtual environment as was recommended in the dbt docs, but that kept causing dependency issues when trying to `pip install dbt-core dbt-duckdb`, and even a clean conda install didn't work the first time, rather surprisingly. Creating a new conda environment with a different, specific version of Python (3.11.8) that I saw had worked for someone on a dbt forum finally resolved the installation snags.

Once I finally got to the real core of the task, after first confirming the connection to DuckDB in a small test python script, and then eventually realizing that I could not run duckdb commands directly in the command line, but instead would need to use the interactive shell, which was not directly mentioned anywhere in the dbt docs, but only in a section of the dbt-duckdb GitHub page, I got underway with staging the data and building the models. Here at least the available docs seemed to cover the key things to know, and learning about Jinja templating and capabilities was neat - I looked to apply what I could.

Needing to use window functions instead of more computationally expensive joins proved trickier for some of the transformations - the year-over-year change in particular took a while to get right. The nature of the dataset meant that windowing didn't always yield exact results, but I used my exploration of the data using the interactive shell to hue as close to the ground truth as possible, and added comments alluding to that in the transformation model file.

## Comparison of dbt and SQL Mesh

Afterwards, I could check the testing and validation capabilities of dbt Core, and both the ease of running the commands and organizing the models was satisfying. I noted the initial setup difficulties, and even some of the lack of CLI workflow clarity, in the previous section, though the eventual CLI workflow experience was positive. Having now gotten past the early learning curve, I'd say the developer experience is solid, but not without potential hiccups.

In terms of enterprise adoption, dbt's strength lies in its ecosystem maturity and extensive community - it's been around for nearly a decade, and has been an industry-leader in the space for quite some time. This is apparent in the tie-ins it has with many data platforms through their Trusted Adapters designation, which has processes in place between partner platforms and dbt Labs to ensure a smooth, integrated experience with dbt, especially in their Cloud offering. The fairly extensive documentation and large, active forums online reflect this as well.

Total cost of ownership changes significantly depending on whether dbt Core or Cloud makes more sense for an organization - that would have much to do with the composition of the teams using the framework, and the scale of the entire operation. If people are comfortable with the CLI, as many
data engineers would be, and they have other orchestration tooling in place for larger projects, then dbt Core can be perfectly serviceable. dbt Cloud has its conveniences with the GUI, and some additional features, like native orchestration, hosting documentation, a semantic layer, multi-project mesh support, etc, but enterprise costs for licenses can add up (in the ballpark of 5k+ per seat annually for enterprise vs 1.2k+ per seat for a standalone, small team). As an industry standard, it has long-term suitability for modern data platforms.

Comparatively, SQLMesh is a newer player on the scene, but they're open-source, and have some significant performance improvements compared to dbt, stemming from its approach to utilizing isolated virtual environments. Additionally, more native understanding of SQL due to parsing via SQLGlot instead of leaning on Jinja, and the ability to use Python macros and the open-source UI, along with multi-repository support off the bat, are all welcome differences.

SQLMesh's setup process seems to be on par with dbt, but the entire development loop is more chiseled, not needing a full refresh (though some of this can be mitigated on the dbt side by using an extension like Power User for dbt, which I did throughout the project). Testing capabilities are on par, and validation is slightly stronger due to the aforementioned native SQL understanding, along with data contracts to more clearly identify migration pain points before deploying to production.

CLI workflows are similar, and the developer experience, while not backed with as massive of a community, is still robust. The ecosystem maturity is coming along, and at least using DuckDB as a point of reference, the documentation for integration found in the docs for dbt and SQLMesh are comparable. The infrastructure cost could be lower with SQLMesh, but team ramp-up could be more involved. It would also be suitable long-term for modern data platforms, since it is being maintained by Tobiko Data, which has a paid, Cloud offering separately as well, that should indirectly help with the upkeep of the open source offering.
