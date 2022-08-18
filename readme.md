# Covid19: a project for practicing my SQL + Tableau

1. The data was first downloaded from [Data source](https://ourworldindata.org/covid-deaths) and saved into [csv file](Data/).
2. The downloaded csv files then were imported into [Azure SQL EDGE](https://azure.microsoft.com/en-us/products/azure-sql/edge/) with the import wizard.
3. All data cleaning steps were performed by [SQL](SQLQuery_portfolio).
4. The cleaned SQL tables then were output into [Excel files](Output/) and visualized by [Tableau](https://public.tableau.com/app/profile/tsunghan.hsieh/viz/covid19_16606524256070/1).
5. I ran the [Azure SQL edge](https://azure.microsoft.com/ja-jp/products/azure-sql/edge/#product-overview) on Mac by [docker](https://www.docker.com/).
6. The IDE is [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver16).

- [Data source](https://ourworldindata.org/covid-deaths)
- [Data cleaning](SQLQuery_portfolio)
- [Tableau](https://public.tableau.com/app/profile/tsunghan.hsieh/viz/covid19_16606524256070/1)

![covid](sql_tableau_covid.png)
