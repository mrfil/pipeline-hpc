import pandas as pd
import glob
df = pd.concat([pd.read_csv(f) for f in glob.glob('/datain/*results.csv')], ignore_index = True, sort = True)
df.to_csv('/datain/outputs.csv', encoding='utf-8', index=False)