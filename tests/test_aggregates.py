"""Basic consistency checks for corrected aggregate output in this repository.

These are NOT a substitute for rerunning the complete R model with the source CSVs.
"""
import csv
from pathlib import Path
import unittest

HERE=Path(__file__).resolve().parents[1]
PATH=HERE/'assessment-1-tesla-nvidia'/'results'
def load(file):
    with (PATH/file).open(newline='',encoding='utf-8') as h:
        return list(csv.DictReader(h))

class ResultsTests(unittest.TestCase):
    def test_two_stocks_and_sample(self):
        rows=load('descriptive_statistics.csv')
        self.assertEqual({x['company'] for x in rows},{'Tesla (TSLA)','NVIDIA (NVDA)'})
        for x in rows:
            self.assertEqual(int(x['observations']),1257)
            self.assertEqual(x['start'],'2020-01-03')
            self.assertEqual(x['end'],'2024-12-31')
    def test_corrected_factor_models(self):
        x={(r['company'],r['model']):r for r in load('factor_regressions.csv')}
        expected={('Tesla (TSLA)','CAPM'):.288906,('Tesla (TSLA)','FF3'):.346834,
                  ('NVIDIA (NVDA)','CAPM'):.506139,('NVIDIA (NVDA)','FF3'):.619820}
        for key,r2 in expected.items():
            self.assertAlmostEqual(float(x[key]['r_squared']),r2,places=5)
        for company in ['Tesla (TSLA)','NVIDIA (NVDA)']:
            self.assertGreater(float(x[(company,'FF3')]['r_squared']),float(x[(company,'CAPM')]['r_squared']))
    def test_significant_ljung_box_for_nvda_not_tsla(self):
        rows=load('ljung_box.csv')
        for x in rows:
            if 'NVIDIA' in x['company']: self.assertLess(float(x['p_value']),.05)
            else: self.assertGreater(float(x['p_value']),.05)
    def test_variance_ratio_results_marked_unverified(self):
        rows=load('variance_ratio_from_submitted_report.csv')
        self.assertEqual(len(rows),2)
        for x in rows: self.assertIn('not independently',x['verification'])
if __name__=='__main__': unittest.main()
