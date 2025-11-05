import pandas as pd

sample_json = [
    {
        "customer_id": 1,
        "name": "Alice",
        "purchase_id": 301,
        "date": "2024-06-01",
        "waffles": [
            {"waffle_id": "W1", "quantity": 2},
            {"waffle_id": "W2", "quantity": 1}
        ]
    }
]
if __name__ == '__main__':
    pd.set_option('display.max_rows', 100)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', 200)
    pd.set_option('display.max_colwidth', None)


    df = pd.json_normalize(
        sample_json,
        record_path=["waffles"],
        meta=["customer_id", "name", "purchase_id", "date"]
    )

    # df = pd.json_normalize(sample_json)
    # waffles_df = df.explode('waffles').reset_index(drop=True)
    # waffles_df = pd.concat([waffles_df.drop(columns=['waffles']), waffles_df['waffles'].apply(pd.Series)], axis=1)
    # print(waffles_df)

    print(df)