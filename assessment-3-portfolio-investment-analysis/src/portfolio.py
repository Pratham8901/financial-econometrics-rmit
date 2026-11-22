"""Post-submission portfolio verification; standard library, no third-party dependencies.

Reads locally held data under data/private; deliberately does not ship provider data.
Not an implementation of the submitted GARCH/VAR models.
"""
from __future__ import annotations
from datetime import datetime
from math import log, sqrt
from statistics import covariance, stdev
from pathlib import Path
import csv

DATE_FORMATS=("%m-%d-%y", "%m/%d/%Y", "%Y-%m-%d")

def parse_date(value: str):
    for fmt in DATE_FORMATS:
        try: return datetime.strptime(value.strip(),fmt).date()
        except ValueError: continue
    raise ValueError(f"Unexpected date format: {value!r}")

def read_prices(path: Path):
    with path.open(newline='',encoding='utf-8-sig') as fh:
        rows=list(csv.DictReader(fh))
    if not rows: raise ValueError(f"No rows: {path}")
    observations=[]
    for row in rows:
        date=parse_date(row['Date'])
        price=float(str(row['Price']).replace(',',''))
        if price <= 0: raise ValueError(f"Nonpositive price on {date}")
        observations.append((date,price))
    observations.sort()
    if len({d for d,_ in observations})!=len(observations):
        raise ValueError(f"Duplicate trading date: {path}")
    return observations

def align(first,second):
    if [d for d,_ in first] != [d for d,_ in second]:
        raise ValueError("Price-history dates do not align; reconcile mismatches first")
    return [d for d,_ in first],[x for _,x in first],[x for _,x in second]

def returns_pct(prices):
    return [100*log(b/a) for a,b in zip(prices[:-1],prices[1:])]

def minimum_variance_weight(x,y):
    if len(x)!=len(y) or len(x)<3: raise ValueError("Need at least 3 aligned returns")
    vt,vc=stdev(x)**2, stdev(y)**2
    cv=covariance(x,y)
    den=vt+vc-2*cv
    if den<=0: raise ValueError("Degenerate covariance matrix")
    return max(0.0,min(1.0,(vc-cv)/den))

def portfolio_volatility_pct(x,y,w,trading_days=250):
    a=[w*xt+(1-w)*yt for xt,yt in zip(x,y)]
    return stdev(a)*sqrt(trading_days)

def buy_hold_values(prices_x,prices_y,w,notional=1_500_000.0):
    if len(prices_x)!=len(prices_y) or not prices_x: raise ValueError("Unmatched prices")
    px0,py0=prices_x[0], prices_y[0]
    return [notional*(w*px/px0+(1-w)*py/py0) for px,py in zip(prices_x,prices_y)]

def realised_volatility_pct(values,trading_days=250):
    daily=[100*log(y/x) for x,y in zip(values[:-1],values[1:])]
    return stdev(daily)*sqrt(trading_days)

def max_drawdown_pct(values):
    peak=values[0]
    drawdown=0
    for v in values:
        peak=max(peak,v)
        drawdown=min(drawdown,v/peak-1)
    return 100*drawdown

def verify(directory: Path):
    files={
        'train_tsla':'Tesla Stock Price History(3).csv',
        'train_ko':'Coca-Cola Stock Price History(2).csv',
        'eval_tsla':'Tesla Stock Price History 2025(1).csv',
        'eval_ko':'Coca-Cola Stock Price History 2025(1).csv',
    }
    tables={k:read_prices(directory/v) for k,v in files.items()}
    dates,t,c=align(tables['train_tsla'],tables['train_ko'])
    edates,et,ec=align(tables['eval_tsla'],tables['eval_ko'])
    if str(dates[0])!='2020-01-02' or str(dates[-1])!='2024-12-31':
        raise ValueError('Unexpected training window')
    if str(edates[0])!='2024-12-31' or str(edates[-1])!='2025-12-31':
        raise ValueError('Unexpected evaluation window')
    if t[-1]!=et[0] or c[-1]!=ec[0]:
        raise ValueError('Evaluation starting prices do not match training end')
    x,y=returns_pct(t),returns_pct(c)
    weight=minimum_variance_weight(x,y)
    out={'n_train_returns':len(x),'n_eval_returns':len(edates)-1,
         'min_variance_tsla_weight':weight, 'rounded_tsla_weight':.044}
    for name,w in [('recommended',.044),('equal',.5)]:
        v=buy_hold_values(et,ec,w)
        out[f'historical_vol_{name}_pct']=portfolio_volatility_pct(x,y,w)
        out[f'final_value_{name}_aud']=v[-1]
        out[f'return_{name}_pct']=100*(v[-1]/v[0]-1)
        out[f'realised_vol_{name}_pct']=realised_volatility_pct(v)
        out[f'max_drawdown_{name}_pct']=max_drawdown_pct(v)
    return out
