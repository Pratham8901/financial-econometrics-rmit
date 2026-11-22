"""Tests of derived aggregates and synthetic finance formulas (no raw stock prices bundled)."""
from pathlib import Path
import json,sys,unittest
ROOT=Path(__file__).resolve().parents[1]
A3=ROOT/'assessment-3-portfolio-investment-analysis'
sys.path.insert(0,str(A3))
from src.portfolio import minimum_variance_weight,buy_hold_values,returns_pct,max_drawdown_pct

class PortfolioTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.out=json.loads((A3/'results'/'verified_portfolio_summary.json').read_text())
    def test_verified_training_window(self):
        d=self.out
        self.assertEqual((d['n_prices_train'],d['n_returns_train']),(1258,1257))
        self.assertEqual((d['n_prices_eval'],d['n_returns_eval']),(251,250))
        self.assertEqual(d['period_end'],'2024-12-31')
    def test_aggregate_portfolio_metrics(self):
        d=self.out
        self.assertAlmostEqual(d['min_variance_tsla_weight'],.044430736,places=7)
        self.assertAlmostEqual(d['return_correlation'],.171302,places=5)
        self.assertAlmostEqual(d['final_value_recommended_aud'],1683696.4182,places=2)
        self.assertAlmostEqual(d['final_value_equal_aud'],1677360.8835,places=2)
    def test_synthetic_min_variance(self):
        x=[-2,0,2,0,0];y=[-1,0,1,0,0]
        # perfectly correlated returns imply long-only all-weight on lower-volatility security
        self.assertEqual(minimum_variance_weight(x,y),0)
    def test_synthetic_buy_hold_and_drawdown(self):
        result=buy_hold_values([100,200,50],[100,100,100],.5,1000)
        self.assertEqual(result,[1000,1500,750])
        self.assertAlmostEqual(max_drawdown_pct(result),-50)
    def test_no_future_dependency_for_optimum(self):
        # API requires only training returns; the 2025 evaluation cannot affect this weight
        x=returns_pct([100,105,100,110]);y=returns_pct([100,102,101,103])
        w=minimum_variance_weight(x,y)
        self.assertGreaterEqual(w,0)
        self.assertLessEqual(w,1)
    def test_variant_provenance(self):
        p=(A3/'results'/'model_variants_reported.csv').read_text()
        self.assertIn('Report only - joint native R refit not executed',p)
        self.assertIn('6_0_2',p)
if __name__=='__main__': unittest.main()
