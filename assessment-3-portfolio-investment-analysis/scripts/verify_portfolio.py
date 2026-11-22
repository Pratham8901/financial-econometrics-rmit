"""Run independently verifiable portfolio arithmetic on permitted local CSV data."""
from pathlib import Path
import sys,json
HERE=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(HERE))
from src.portfolio import verify

def main():
    source=HERE/'data'/'private'
    if not source.is_dir():
        raise SystemExit(f"Create {source} and add the four permitted CSV files (see data/README.md)")
    try:
        values=verify(source)
    except (FileNotFoundError, ValueError) as ex:
        raise SystemExit(f"Input validation failed: {ex}") from ex
    print(json.dumps(values,indent=2))
if __name__=='__main__': main()
