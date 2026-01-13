import polars as pl

df = pl.DataFrame({
    'nums': [1, 2, 3, 4, 5],
    'letters': ['a', 'b', 'c', 'd', 'e']
})

print(df.head())


df = pl.read_csv('titanic_dataset.csv')
print(df.head)


print(df.schema)