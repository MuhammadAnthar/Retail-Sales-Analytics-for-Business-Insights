SELECT
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_quantity
from superstore.order_items oi 
 
#Rata-rata penjualan tiap order
select 
	round(sum(oi.sales)/count(distinct oi.order_id),2) AS ratarata_nilai_per_order
from superstore.order_items oi 

#Presentase Keuntungan
SELECT
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales), 0)) * 100, 2) AS profit_margin_pct
FROM superstore.order_items oi;

#presentase barang return	
select 
	round(
	count(r.order_id)::numeric / nullif (count(o.order_id), 0) *100, 
	2) AS persentase_barang_return
from superstore."returns" r 
right join superstore.orders o 
	on 	r.order_id = o.order_id
	
SELECT 
    ROUND(
        COUNT(r.order_id)::numeric / NULLIF(COUNT(o.order_id), 0) * 100,
        2
    ) AS persentase_barang_return
FROM superstore.orders o 
LEFT JOIN superstore."returns" r 
    ON o.order_id = r.order_id ;

 #trend penjualan  
 SELECT
    EXTRACT(YEAR FROM o.order_date) AS tahun,
    EXTRACT(MONTH FROM o.order_date) AS bulan,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM superstore.orders o
JOIN superstore.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY tahun, bulan;

 SELECT
    EXTRACT(YEAR FROM o.order_date) AS tahun,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales), 0)) * 100, 2) AS profit_margin_pct
FROM superstore.orders o
JOIN superstore.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(YEAR FROM o.order_date)
ORDER BY tahun;

#penjualan barang
select 
	p.product_name as nama_produk,
	sum(oi.quantity) as jumlah_produk_terjual 
from superstore.products p 
join superstore.order_items oi 
	on p.product_id = oi.product_id 
join superstore.orders o 
	on oi.order_id = o.order_id 
group by
	p.product_name 
order by jumlah_produk_terjual desc;


#Growth bulanan
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month_date,
        ROUND(SUM(oi.sales), 2) AS total_sales,
        ROUND(SUM(oi.profit), 2) AS total_profit,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM superstore.orders o
    JOIN superstore.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    month_date,
    total_sales,
    total_profit,
    total_orders,
    ROUND(
        (
            (total_sales - LAG(total_sales) OVER (ORDER BY month_date))
            / NULLIF(LAG(total_sales) OVER (ORDER BY month_date), 0)
        ) * 100,
        2
    ) AS sales_growth_pct,
    ROUND(
        (
            (total_profit - LAG(total_profit) OVER (ORDER BY month_date))
            / NULLIF(LAG(total_profit) OVER (ORDER BY month_date), 0)
        ) * 100,
        2
    ) AS profit_growth_pct
FROM monthly_sales
ORDER BY month_date;

#Return rate per region
SELECT
    r.region_name AS wilayah,
    COUNT(DISTINCT o.order_id) AS total_order,
    COUNT(DISTINCT rt.order_id) AS total_return,
    ROUND(
        COUNT(DISTINCT rt.order_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT o.order_id), 0) * 100,
        2
    ) AS return_rate_pct
FROM superstore.regions r
JOIN superstore.orders o 
    ON r.region_id = o.region_id
LEFT JOIN superstore.returns rt
    ON o.order_id = rt.order_id
GROUP BY r.region_name
ORDER BY return_rate_pct DESC;

#Profitability per category dan sub-category
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(
        (SUM(oi.profit) / NULLIF(SUM(oi.sales), 0)) * 100,
        2
    ) AS profit_margin_pct,
    SUM(oi.quantity) AS total_quantity
FROM superstore.order_items oi
JOIN superstore.products p
    ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_profit DESC;

#Produk rugi / unprofitable products
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2) AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    SUM(oi.quantity) AS total_quantity
FROM superstore.order_items oi
JOIN superstore.products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category, p.sub_category
HAVING SUM(oi.profit) < 0
ORDER BY total_profit ASC;

WITH yearly_kpi AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        SUM(oi.sales) AS sales,
        SUM(oi.profit) AS profit,
        COUNT(DISTINCT o.order_id) AS orders,
        AVG(oi.discount) AS discount
    FROM superstore.orders o
    JOIN superstore.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT
    year,
    ROUND(sales, 2) AS sales,
    ROUND(profit, 2) AS profit,
    orders,
    ROUND(discount, 2) AS discount,
    ROUND((profit / NULLIF(sales, 0)) * 100, 2) AS margin_pct,
    ROUND(sales / NULLIF(orders, 0), 2) AS aov,
    ROUND(
        ((sales - LAG(sales) OVER (ORDER BY year))
        / NULLIF(LAG(sales) OVER (ORDER BY year), 0)) * 100,
        2
    ) AS sales_growth_pct,
    ROUND(
        ((profit - LAG(profit) OVER (ORDER BY year))
        / NULLIF(LAG(profit) OVER (ORDER BY year), 0)) * 100,
        2
    ) AS profit_growth_pct,
    ROUND(
        ((orders - LAG(orders) OVER (ORDER BY year))
        / NULLIF(LAG(orders) OVER (ORDER BY year), 0)) * 100,
        2
    ) AS orders_growth_pct,
    ROUND(
        ((discount - LAG(discount) OVER (ORDER BY year))
        / NULLIF(LAG(discount) OVER (ORDER BY year), 0)) * 100,
        2
    ) AS discount_growth_pct
FROM yearly_kpi
ORDER BY year;