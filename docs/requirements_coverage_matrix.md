# 09. Requirements Coverage Matrix

This matrix maps each assignment requirement to the corresponding project documentation and implementation expectation.

| Requirement Area       | Requirement Detail                          | Coverage Status | Primary Document(s)                                                               |
| ---------------------- | ------------------------------------------- | --------------- | --------------------------------------------------------------------------------- |
| Source DB Setup        | MySQL on Docker                             | Covered         | `business_requirements.md`, `demo_runbook_end_to_end.md`                          |
| Source DB Setup        | Create tables from DDL                      | Covered         | `business_requirements.md`                                                        |
| Source DB Setup        | Load all data into MySQL                    | Covered         | `business_requirements.md`, `demo_runbook_end_to_end.md`                          |
| Warehouse Setup        | PostgreSQL local simulation of AWS RDS      | Covered         | `business_requirements.md`, `README.md`                                           |
| Pipeline Orchestration | Airflow + dbt via Docker                    | Covered         | `business_requirements.md`, `README.md`                                           |
| Raw Zone               | Load MySQL to PostgreSQL raw                | Covered         | `business_requirements.md`, `table_mapping_raw_silver_gold.md`                    |
| Raw Zone               | Store fields as text                        | Covered         | `business_requirements.md`, `table_mapping_raw_silver_gold.md`                    |
| Raw Zone               | Apply SCD where applicable                  | Covered         | `data_quality_rules.md`, `scd_specification.md`                                   |
| Silver Zone            | Clean and validate data                     | Covered         | `data_quality_rules.md`, `dq_rule_catalog.md`                                     |
| Silver Zone            | Date and business validation rules          | Covered         | `dq_rule_catalog.md`                                                              |
| Silver Zone            | Separate valid and invalid records          | Covered         | `data_quality_rules.md`, `dq_rule_catalog.md`, `table_mapping_raw_silver_gold.md` |
| Monitoring             | Teams alert on success                      | Covered         | `business_requirements.md`, `demo_runbook_end_to_end.md`                          |
| Monitoring             | Teams alert on failure                      | Covered         | `business_requirements.md`, `demo_runbook_end_to_end.md`                          |
| Monitoring             | Teams alert on DQ failure summary           | Covered         | `business_requirements.md`, `dq_rule_catalog.md`, `demo_runbook_end_to_end.md`    |
| Data Analysis          | Assess overall data quality                 | Covered         | `dq_rule_catalog.md`, `demo_runbook_end_to_end.md`                                |
| Data Analysis          | Identify revenue improvement insights       | Covered         | `data_modeling_gold.md`                                                           |
| Data Analysis          | Extend Silver to Gold for visualization     | Covered         | `data_modeling_gold.md`, `table_mapping_raw_silver_gold.md`                       |
| Visualization          | Use Power BI or open-source tool            | Covered         | `business_requirements.md`, `README.md`                                           |
| Presentation & Demo    | Present architecture and outcomes           | Covered         | `00_docs_index.md`, `demo_runbook_end_to_end.md`                                  |
| Presentation & Demo    | Insert new source record and run end-to-end | Covered         | `demo_runbook_end_to_end.md`                                                      |

## Coverage Assessment

- Documentation completeness for requirement traceability: **Complete**
- Implementation readiness (documentation level): **High**
- Remaining work (outside docs): implement and validate actual Docker/Airflow/dbt code artifacts
