"""Check saved aggregate derived tables; no raw third-party data bundled."""
from pathlib import Path
import csv,unittest
ROOT=Path(__file__).resolve().parents[1]
DIR=ROOT/'assessment-2-tesla-coca-cola'/'results'
def table(f):
    with (DIR/f).open(encoding='utf-8') as handle: return list(csv.DictReader(handle))
class Assessment2AggregateTests(unittest.TestCase):
    def test_sample_and_volatility(self):
        rows={x['symbol']:x for x in table('return_statistics_verified.csv')}
        self.assertEqual(set(rows),{'TSLA','KO'})
        self.assertTrue(all(int(row['observations'])==1257 for row in rows.values()))
        self.assertAlmostEqual(float(rows['TSLA']['sd_daily_percent']),4.22075908,places=5)
        self.assertAlmostEqual(float(rows['KO']['sd_daily_percent']),1.31791789,places=5)
    def test_ljung_box(self):
        rows={(x['symbol'],int(x['lag'])):x for x in table('ljung_box_verified.csv')}
        self.assertAlmostEqual(float(rows['TSLA',9]['p_value']),0.16961999,places=5)
        self.assertAlmostEqual(float(rows['KO',2]['p_value']),0.00449407,places=6)
    def test_provenance(self):
        self.assertEqual(len(table('mean_model_comparison_reported.csv')),8)
        self.assertEqual(len(table('volatility_model_comparison_reported.csv')),10)
        self.assertTrue(all('not independently' in x['source'].lower() for x in table('mean_model_comparison_reported.csv')))
if __name__=='__main__':unittest.main()
