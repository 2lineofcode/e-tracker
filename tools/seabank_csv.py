import pandas as pd
import uuid
import fitz
import re
from datetime import datetime


PDF_PATH = "4.pdf"
OUTPUT_PATH = "4.csv"
STATEMENT_YEAR = 2025
STATEMENT_MONTH = 4
DATE_PATTERN = re.compile(r"^\d{2} APR$")
MIN_AMOUNT = 5_000
TARGET_TYPES = {"Pembayaran", "Transfer", "Top Up - eWallet", "Bill - Token Listrik"}
# TARGET_TYPES = {"Pembayaran"}
BANK_KEYWORDS = ["bca", "bri", "seabank", "bni"]
EWALLET_KEYWORDS = ["ovo", "dana", "gopay", "shopeepay", "linkaja"]
TYPE_MARKERS = { "Bunga", "Pajak", "Pembayaran", "Transfer", "Top Up - eWallet", "Bill - Token Listrik", }
SKIP_NOTES = {"aditya pratama bank jago syariah 504162065243", "Aditya Pratama Superbank 000059601120"}


def parse_amount(value: str) -> int:
    cleaned = value.replace(".", "").replace(",", "")
    if not cleaned.isdigit():
        raise ValueError(f"Angka tidak valid: {value}")
    return int(cleaned)


def normalize_text(value: str) -> str:
    return " ".join(value.split()).strip()


def extract_statement_rows(pdf_path: str):
    with fitz.open(pdf_path) as doc:
        text = "\n".join(page.get_text("text") for page in doc)

    lines = [line.strip() for line in text.splitlines() if line.strip()]
    entries = []
    prev_balance = None
    i = 0
    total_lines = len(lines)

    while i < total_lines:
        if not DATE_PATTERN.match(lines[i]):
            i += 1
            continue

        date_token = lines[i]
        i += 1

        description_parts = []
        txn_type = None
        while i < total_lines:
            line = lines[i]
            if line in TYPE_MARKERS:
                txn_type = line
                break
            if DATE_PATTERN.match(line):
                # Unexpected new date; rewind one step so outer loop can handle it.
                i -= 1
                break
            description_parts.append(line)
            i += 1

        if txn_type is None or i + 2 >= total_lines:
            i += 1
            continue

        note_raw = normalize_text(" ".join(description_parts))
        i += 1
        amount_raw = lines[i]
        i += 1
        balance_raw = lines[i]
        i += 1

        try:
            amount_val = parse_amount(amount_raw)
            balance_val = parse_amount(balance_raw)
        except ValueError:
            prev_balance = None
            continue

        direction = None
        if prev_balance is not None:
            if balance_val < prev_balance:
                direction = "out"
            elif balance_val > prev_balance:
                direction = "in"
            else:
                direction = "flat"

        prev_balance = balance_val
        entries.append(
            {
                "date_token": date_token,
                "note": note_raw.title(),
                "type": txn_type,
                "amount": amount_val,
                "balance": balance_val,
                "direction": direction,
            }
        )

    return entries


def infer_category(note: str) -> str:
    n = note.lower()
    if any(x in n for x in ["warung", "gado", "ayam", "soto", "kebuli", "minang", "bu mar", "nasi", "rm "]):
        return "expense:basic:food"
    if any(x in n for x in ["coffee", "kopi", "fore", "jago", "kenangan", "butter", "salad"]):
        return "expense:basic:snacks-coffee"
    if any(x in n for x in ["pln", "token", "air", "listrik", "laundry"]):
        return "expense:basic:housing-needs"
    if any(x in n for x in ["f&b", "pestapora", "event", "bioskop", "cinema"]):
        return "expense:entertainment:social"
    if any(x in n for x in ["smartfren", "subscription", "spotify", "youtube", "netflix"]):
        return "expense:bill:subscription"
    if any(x in n for x in ["vapor", "smoke", "vape"]):
        return "expense:basic:smoke"
    if any(x in n for x in ["bengkel", "auto", "wash", "fuel", "bensin", "pertamina"]):
        return "expense:transport:maintenance"
    if any(x in n for x in ["shopee", "tokopedia", "blibli", "lazada", "pay"]):
        return "expense:basic:groceries"
    return "expense:unknown"


def to_iso_date(token: str) -> str:
    day = int(token.split()[0])
    dt = datetime(STATEMENT_YEAR, STATEMENT_MONTH, day)
    return dt.strftime("%Y-%m-%d")


def build_dataframe(rows):
    filtered = []
    for row in rows:
        if row["type"] not in TARGET_TYPES:
            continue
        if row["amount"] <= MIN_AMOUNT:
            continue
        if row["type"] == "Transfer" and row.get("direction") != "out":
            continue
        note_lower = row["note"].lower()
        if any(skip.lower() in note_lower for skip in SKIP_NOTES):
            continue
        note_text, detail_text = split_note_and_detail(row["note"], row["type"])
        filtered.append(
            {
                "date": to_iso_date(row["date_token"]),
                "note": note_text,
                "detail": detail_text,
                "amount": row["amount"],
            }
        )

    df = pd.DataFrame(filtered)
    if df.empty:
        return df

    df["category_name"] = df["note"].apply(infer_category)
    df["created_at"] = f"2025-0{STATEMENT_MONTH}-01 00:00:00+00"
    df["user_id"] = "25aa9f27-18cb-407d-9141-ffab6a50cab8"
    df["id"] = [str(uuid.uuid4()) for _ in range(len(df))]
    final_cols = ["id", "user_id", "date", "note", "detail", "amount", "category_name", "created_at"]
    return df[final_cols]


def split_note_and_detail(note: str, txn_type: str):
    if txn_type == "Transfer":
        return split_transfer_detail(note)
    if txn_type == "Top Up - eWallet":
        return split_topup_detail(note)
    return note, ""


def split_transfer_detail(note: str):
    lowered = note.lower()
    for bank in BANK_KEYWORDS:
        idx = lowered.find(bank)
        if idx != -1:
            name_part = note[:idx].strip()
            detail_part = note[idx:].strip()
            return name_part or note, detail_part
    return note, ""


def split_topup_detail(note: str):
    lowered = note.lower()
    for keyword in EWALLET_KEYWORDS:
        idx = lowered.find(keyword)
        if idx != -1:
            name_part = note[:idx].strip()
            detail_part = note[idx:].strip()
            return name_part or note, detail_part
    return note, ""


statement_rows = extract_statement_rows(PDF_PATH)
df_final = build_dataframe(statement_rows)

if df_final.empty:
    raise SystemExit("Tidak ada transaksi yang cocok dengan filter.")

df_final.to_csv(OUTPUT_PATH, index=False)
print(OUTPUT_PATH)
