import json
from collections import defaultdict
from typing import Optional

import pytest
import pandas as pd
from pydantic import BaseModel


sample_json = [
    {
        "customer_id": 1,
        12: 20,
        13: [{"a": [1, 2,3]}, {"a": [4, 5]}],
        14: [{1000: [1, 2,3]}, {1000: [4, 5]}],
        "name": "Alice",
        "purchases": [
            {
                "purchase_id": 301,
                "date": "2024-06-01",
                "waffles": [
                    {"waffle_id": "W1", "type": "Belgian", "flavor": "Vanilla", "quantity": 2},
                    {"waffle_id": "W2", "type": "Chocolate", "flavor": "Chocolate", "quantity": 1}
                ]
            },
            {
                "purchase_id": 302,
                "date": "2024-06-10",
                "waffles": [
                    {"waffle_id": "W3", "type": "Strawberry", "flavor": "Strawberry", "quantity": 3}
                ]
            }
        ]
    }
]

@pytest.mark.parametrize(
    "args",
    [
        pytest.param({}, id="no args (base case)"),
        pytest.param( dict(record_path=[13]), id="int as record path"),
        pytest.param( dict(record_path=[13, "a"]), id="int and str as record path"),
        pytest.param( dict(record_path=[14, 1_000]), id="int + int as record path"),
        pytest.param(dict(meta=[12]), id="int as meta field"),
        pytest.param(dict(meta=[12, 13]), id="int + int as meta field"),
        pytest.param(dict(meta=[12, "name"]), id="int + string as meta fields"),
        pytest.param(dict(meta=["name", 12]), id="int + string as meta fields (2)"),

        pytest.param(dict(record_path=["purchases"], meta=[12]), id="int as meta & record path"),
        pytest.param(dict(record_path=["purchases"], meta=[12, 13]), id="int +int as meta & record path"),
        pytest.param(dict(record_path=["purchases"], meta=[12, "name"]), id="int + string as meta fields & record path"),
        pytest.param(dict(record_path=["purchases"], meta=["name", 12]), id="int + string as meta fields & record path(2)"),

        pytest.param(
            dict(meta=['customer_id', 'name']),
            id="meta args"
        ),
        pytest.param(
            dict(record_path=["purchases"], meta=['customer_id', 'name', 12]),
            id="meta args + record path"
        )
    ]
)
def test_opposite_normalize(args: dict, data: dict = sample_json):
    """"
    Load using pandas json_normalize and try to get the
    starting data back
    """
    df = pd.json_normalize(data, **args)
    result = df_opposite_json_normalize(df, **args)

    assert result == data



def df_opposite_json_normalize(
    df,
    sep=".",
    record_path: Optional[list[str]] = None,
    meta: Optional[list[str]] = None):
    """
    The opposite of json_normalize
    """
    result = []
    result_dict = defaultdict(list)  # used when record_path arg is used

    for _, row in df.iterrows():
        parsed_row = {}

        # grab meta fields
        meta_values = {meta_key: row[meta_key] for meta_key in (meta or [])}

        for col_label,v in row.items():

            # assuming your dict has keys that aren't strings
            # otherwise, simplify with just: keys = col_label.split(sep)
            if isinstance(col_label, str):
                keys = col_label.split(sep)
            else:
                keys = [col_label]

            current = parsed_row
            for i, k in enumerate(keys):
                # meta fields belong in the root, not in the nested obj
                if meta and k in meta:
                    continue
                if i==len(keys)-1:
                    current[k] = v
                else:
                    if k not in current.keys():
                        current[k] = {}
                    current = current[k]

        if record_path and len(record_path) ==1:
            key = tuple(meta_values.values())
            result_dict[key].append(parsed_row)
            continue

        # Include meta values in result
        if meta_values:
            parsed_row.update(meta_values)

        result.append(parsed_row)

    # Unpack default dict into list
    if record_path and len(record_path) ==1:
        result = [
            {**dict(zip(meta, key)), record_path[0]: value}
            for key, value in result_dict.items()
        ]

    return result


# df = pd.json_normalize(sample_json)
df = pd.json_normalize(sample_json, record_path=["purchases"], meta=['customer_id', 'name'])


if __name__ == '__main__':
    pd.set_option('display.max_rows', 100)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', 200)
    pd.set_option('display.max_colwidth', None)
    # print(df)
    # print(df.explode('waffles')['waffles'].apply(pd.Series))
    df = pd.json_normalize(sample_json, record_path=["purchases"], meta=['customer_id', 'name'])
    new_df = df.explode('waffles')['waffles'].apply(pd.Series)

    joined_df = pd.concat([new_df, df.drop(columns=['waffles'])], axis=1)
    print(joined_df)
