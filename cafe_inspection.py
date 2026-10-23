import pandas as pd  # Import pandas for data analysis

# Load the café sales dataset
df = pd.read_csv("cafe_sales.csv")

# Display the first 5 rows
print(df.head())

# Display column names, data types, and non-null counts
print(df.info())

# Count missing values in each column
print("MISSING VALUES")
print(df.isnull().sum())

# Count duplicate rows
print("Duplicates:", df.duplicated().sum())

# Check distinct values in categorical columns
for column in ["Item", "Payment Method", "Location"]:
    print(f"\n{column}:")
    print(df[column].unique())

# Check for values that cannot be converted to numbers
for column in ["Quantity", "Price Per Unit", "Total Spent"]:
    values = pd.to_numeric(df[column], errors="coerce")

    print(f"\n{column} - invalid values:")
    print(df.loc[values.isna() & df[column].notna(), column].unique())

# Remove extra spaces and standardise invalid placeholders
for column in df.columns:
    if df[column].dtype == "object":
        df[column] = df[column].str.strip()

df.replace(["ERROR", "UNKNOWN", ""], pd.NA, inplace=True)

# Convert numeric columns to appropriate data types
for column in ["Quantity", "Price Per Unit", "Total Spent"]:
    df[column] = pd.to_numeric(df[column], errors="coerce")

# Check the updated data types and missing values
print(df.dtypes)
print(df.isnull().sum())

# Convert Transaction Date to datetime format
df["Transaction Date"] = pd.to_datetime(
    df["Transaction Date"], errors="coerce"
)

# Check the date data type and missing values
print(df["Transaction Date"].dtype)
print(df["Transaction Date"].isnull().sum())

# Check missing values in each column
print(df.isnull().sum())

# Check missing values in numerical columns
numeric_columns = ["Quantity", "Price Per Unit", "Total Spent"]

print(df[numeric_columns].isnull().sum())

# Calculate missing totals when quantity and price are available
can_calculate_total = (
    df["Total Spent"].isna()
    & df["Quantity"].notna()
    & df["Price Per Unit"].notna()
)

df.loc[can_calculate_total, "Total Spent"] = (
    df.loc[can_calculate_total, "Quantity"]
    * df.loc[can_calculate_total, "Price Per Unit"]
)

print("Missing totals recovered:", can_calculate_total.sum())

# Find missing quantities we can calculate
can_calculate_quantity = (
    df["Quantity"].isnull()
    & df["Total Spent"].notnull()
    & df["Price Per Unit"].notnull()
    & (df["Price Per Unit"] != 0)
)

print(
    "Missing quantities we can calculate:",
    can_calculate_quantity.sum()
)

# Calculate possible missing quantities
calculated_quantity = (
    df["Total Spent"] / df["Price Per Unit"]
)

# Accept only positive whole-number quantities
valid_quantity = (
    can_calculate_quantity
    & (calculated_quantity > 0)
    & (
        (calculated_quantity - calculated_quantity.round()).abs()
        < 0.000001
    )
)

# Fill only quantities that can be calculated reliably
df.loc[valid_quantity, "Quantity"] = calculated_quantity[valid_quantity]

print("Missing quantities recovered:", valid_quantity.sum())

# Find missing prices we can calculate
can_calculate_price = (
    df["Price Per Unit"].isnull()
    & df["Total Spent"].notnull()
    & df["Quantity"].notnull()
    & (df["Quantity"] != 0)
)

print(
    "Missing prices we can calculate:",
    can_calculate_price.sum()
)

# Calculate possible missing prices
calculated_price = df["Total Spent"] / df["Quantity"]

# Keep only missing prices with positive calculated values
valid_price = (
    can_calculate_price
    & (calculated_price > 0)
)

# Count how many prices can be recovered
print(
    "Missing prices with positive calculated values:",
    valid_price.sum()
)

# Fill missing prices using the calculated values
df.loc[valid_price, "Price Per Unit"] = calculated_price[valid_price]

# Check how many missing prices remain
print("Missing prices remaining:", df["Price Per Unit"].isnull().sum())

# Display rows with remaining missing numerical values
remaining_missing = df[
    df[["Quantity", "Price Per Unit", "Total Spent"]]
    .isnull()
    .any(axis=1)
]

print(remaining_missing.head(10))

# Recalculate totals where they are still missing
can_calculate_total_again = (
    df["Total Spent"].isna()
    & df["Quantity"].notna()
    & df["Price Per Unit"].notna()
)

df.loc[can_calculate_total_again, "Total Spent"] = (
    df.loc[can_calculate_total_again, "Quantity"]
    * df.loc[can_calculate_total_again, "Price Per Unit"]
)

# Check remaining missing totals
print("Missing totals remaining:", df["Total Spent"].isnull().sum())

# Check remaining missing values in numerical columns
numeric_columns = ["Quantity", "Price Per Unit", "Total Spent"]

print(df[numeric_columns].isnull().sum())

# Check remaining missing values
print("Missing transaction dates:", df["Transaction Date"].isnull().sum())

# Label missing categorical values
categorical_columns = ["Item", "Payment Method", "Location"]

for column in categorical_columns:
    df[column] = df[column].fillna("Unknown")

# Check the final dataset
print("Dataset shape:", df.shape)
print("\nMissing values in each column:")
print(df.isnull().sum())

# Final check for inconsistent numerical values
complete = df[numeric_columns].notna().all(axis=1)

mismatch = complete & (
    (df["Total Spent"] - df["Quantity"] * df["Price Per Unit"]).abs()
    > 0.01
)

print("\nFinal mismatched totals:", mismatch.sum())

print(df.loc[mismatch, [
    "Transaction ID",
    "Item",
    "Quantity",
    "Price Per Unit",
    "Total Spent"
]].head(20))

# Save the cleaned dataset for SQL and Excel
df.to_csv("cafe_sales_cleaned.csv", index=False)
df.to_excel("cafe_sales_cleaned.xlsx", index=False)

print("\nCleaned datasets saved successfully.")
