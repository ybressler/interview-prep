# Interview Prep
Resources for helping me prepare for interviews.

* [Algorithms](./algos/)
* **SQL Questions:**
  * [Customer Data](./questions/customers/CUSTOMERS.md)


# SQL Interview Prep
I've created some tables in the [`database`](./database/) directory.
Will provide specific questions for each dataset.

# Getting Started

## Install Python Dependencies
Install everything with:
```bash
uv sync
```

> [!NOTE]
> Assumes you have `uv` installed: https://docs.astral.sh/uv/getting-started/installation/

## Set up DB
I don't have an automated way to do this yet - create a DB connection to duckdb through your IDE. (You'll need to download the drivers.) Then, run the DDL commands under [`database/`](./database/).

Then you're done.
