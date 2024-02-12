## TWS - Inventory Analysis.

### Introduction.

TWS (The Wine Store), a fictitious wine manufacturer, requires a holistic analysis of its inventory for the year 2016.

### Problem Statement.

1. How has the sales performance been during 2016?
2. Which brands performed the best?
3. What has been the inventory turnover during 2016?
4. Are there any significant sales patterns?

### Analysis Questions:

#### Sales Performance Ranking.
--Rank the brands based on their total sales dollars, considering a rolling window of the last two months. Identify brands with consistent high rankings.

#### Inventory Turnover Rate:
--Calculate the inventory turnover rate for each brand over time, considering a cumulative window. Identify brands with the most dynamic inventory turnover.

#### Price Elasticity:
--Determine the price elasticity of demand for each brand by analyzing the percentage change in sales quantity in response to a percentage change in price within a specific time window.

#### Vendor Contribution Over Time:
--Calculate the contribution of each vendor to total sales. Identify vendors with sustained high contributions.

#### Calculate the cumulative contribution of each vendor to total sales over two months. Identify vendors with sustained high contributions.
--Solution: Basic query structure, with each vendor's sale cotribution calculated through a subquery over two months.

#### Profit Margin Trends:
--Analyze the trend in profit margins for each brand over the last two months using a rolling window. Identify brands with improving or declining profit margins.

#### Geographical Sales Patterns:
--Calculate the average of sales for each city, considering a window of the last two months. Identify cities with the most consistent sales growth.

#### Correlation between Pricing and Sales:
--Calculate the correlation coefficient between average sales prices and sales quantities over a rolling window of two months for each brand.

#### Store-Level Performance Comparison:
--Rank stores based on their sales performance compared to the average sales. Identify stores that consistently outperform or underperform.



