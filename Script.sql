with F1 as (with Final as (select *,
(Expected_charges_X - BillingAmount_Rs) as Amnt_Diff
from 
(select *, (Fixed_charges_X+(additional_charges_X*additional_wt)) as Expected_charges_X
from 
(select * , 
(case when ZoneX = 'a' and Shipment_Type = 'Forward charges' then 29.5
     when ZoneX = 'a' and Shipment_Type = 'Forward and RTO charges' then 29.5 + 13.6
     when ZoneX = 'b' and Shipment_Type = 'Forward charges' then 33
     when ZoneX = 'b' and Shipment_Type = 'Forward and RTO charges' then 33 + 20.5
     when ZoneX = 'c' and Shipment_Type = 'Forward charges' then 40.1
     when ZoneX = 'c' and Shipment_Type = 'Forward and RTO charges' then 40.1 + 31.9
     when ZoneX = 'd' and Shipment_Type = 'Forward charges' then 45.4
     when ZoneX = 'd' and Shipment_Type = 'Forward and RTO charges' then 45.4 + 41.3
     when ZoneX = 'e' and Shipment_Type = 'Forward charges' then 56.6
     Else 56.6 + 50.7
     End) as Fixed_charges_X,
 (case when ZoneX = 'a' and Shipment_Type = 'Forward charges' then 23.6
     when ZoneX = 'a' and Shipment_Type = 'Forward and RTO charges' then 23.6+23.6
     when ZoneX = 'b' and Shipment_Type = 'Forward charges' then 28.3
     when ZoneX = 'b' and Shipment_Type = 'Forward and RTO charges' then 28.3+28.3
     when ZoneX = 'c' and Shipment_Type = 'Forward charges' then 38.9
     when ZoneX = 'c' and Shipment_Type = 'Forward and RTO charges' then 38.9 + 38.9
     when ZoneX = 'd' and Shipment_Type = 'Forward charges' then 44.8
     when ZoneX = 'd' and Shipment_Type = 'Forward and RTO charges' then 44.8 + 44.8
     when ZoneX = 'e' and Shipment_Type = 'Forward charges' then 55.5
     Else 55.5 + 55.5
     End) as additional_charges_X,
     abs(ceiling(TTL_WT_X_kg - 0.5)/0.5) as additional_wt
from 
(select t1.Order_ID, t1.AWB_Code,t2.TTL_WT_X_kg,
t2.weight_slab, t1.Charged_Weight, t1.weight_slab_Y,
t1.ZoneX, t1.Zone, t1.BillingAmount_Rs, t1.Shipment_Type from 
(with new_y as (select * , (case when Charged_Weight <= 0.4 then 0.5
		        when Charged_Weight <= 0.95 then 1
                when Charged_Weight <= 1.4 then 1.5
                when Charged_Weight <= 1.95 then 2
                when Charged_Weight <= 2.4 then 2.5
                when Charged_Weight <= 2.95 then 3
                else 4
           end) as weight_slab_Y from cointab.courier_company_invoice)
select Y.*, pin.Zone as ZoneX from new_y Y
join pincodes_x pin
on Y.Customer_Pincode = pin.Cust_pin) t1
join 
(with k as (with cte as (Select CO.ExternOrderNo, CO.OrderQty*CO.Weight as TTL_weight 
             from cointab.order_report_company_x as CO)
select ExternOrderNo,(sum(TTL_weight)/1000) as TTL_WT_X_kg
from cte
group by ExternOrderNo)
select *, (case when TTL_WT_X_kg <= 0.4 then 0.5
		        when TTL_WT_X_kg <= 0.95 then 1
                when TTL_WT_X_kg <= 1.4 then 1.5
                when TTL_WT_X_kg <= 1.95 then 2
                when TTL_WT_X_kg <= 2.4 then 2.5
                when TTL_WT_X_kg <= 2.95 then 3
                else 4
           end) as weight_slab from k
order by k.TTL_WT_X_kg desc) t2
on t1.Order_ID = t2.ExternOrderNo) Final_tab) Final_tab2) TF)
select Order_ID, AWB_Code, TTL_WT_X_kg, weight_slab as weight_slab_X , Charged_Weight as Charged_Weight_Y , 
weight_slab_Y,ZoneX,Zone as Zone_Y , Expected_charges_X , BillingAmount_Rs as BillingAmount_Rs_Y , Amnt_Diff
from Final)
select count(Order_ID) as count, sum(Amnt_Diff) as 'Amount(RS)'
from F1
where Amnt_Diff = 0
Union
select count(Order_ID) as count, sum(Amnt_Diff) as 'Amount(RS)'
from F1
where Amnt_Diff > 0
Union
select count(Order_ID) as count, sum(Amnt_Diff) as 'Amount(RS)'
from F1
where Amnt_Diff < 0;











