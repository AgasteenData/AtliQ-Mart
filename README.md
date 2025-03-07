# AtliQ Mart Dashboard

### Dashboard Link : https://app.powerbi.com/links/EomZMkSSiq?ctid=31512f93-5b18-4f53-bdef-70f26a7ac9f1&pbi_source=linkShare

## Business Context

AtliQ Mart is a retail giant with over 50 supermarkets in the southern region of India. All their 50 stores ran a 
massive promotion during the Diwali 2023 and Sankranti 2024 (festive time in India) on their AtliQ branded 
products. These promotions aimed to boost sales and enhance customer engagement during these significant 
cultural celebrations. However, the effectiveness of these promotions needs to be evaluated to make informed 
decisions for future marketing strategies. Sales Director Bruce Haryali requires insights into which promotions 
performed well and which ones fell short to optimize future promotional efforts.

## Business Problem 

The primary business problem is to analyze the effectiveness of the Diwali 2023 and Sankranti 2024 
promotions on AtliQ branded products across all 50 AtliQ Mart stores in the southern region of India. This 
analysis involves understanding sales performance metrics, identifying successful promotional strategies, 
determining customer preferences for improvement. The objective is to provide insights to the sales director to 
optimize future promotional activities and to drive sales growth.


### Steps followed 

- Step 1 : Load data into Power BI Desktop,  dataset is a csv file.

- Step 2 : Open power query editor & in view tab under Data preview section, check "column distribution", "column quality" & "column profile" options.
- Step 3 : Also since by default, profile will be opened only for 1000 rows so you need to select "column profiling based on entire dataset".
- Step 4 : It was observed that in none of the columns errors & empty values.  
- Step 5 : In the report view, under the view tab, theme was selected.
- Step 6: In Model View, establish relationships between all tables by dragging and connecting relevant fields.
- Step 7: Ensure proper cardinality (one-to-many, many-to-one) and cross-filter direction for accurate data modeling. 
- Step 8 : Created the Store Performance Analysis report as the first report.
- Step 9 : Visual filters (Slicers) were added for Two fields named Country and Promotion Type 
- Step 10 : Analyzed key metrics to evaluate store performance.

Following DAX expression was written for the same,
        
        Total Stores = COUNTROWS(dim_stores)
        
A card visual was used to represent Total Stores

![Image](https://github.com/user-attachments/assets/a4cc0bb6-cdee-4a7b-85c5-0e7c96ddeb62)

A card visual was used to represent Total Revenue Before promotions
        
        Total_Rev_Before = fact_events[base_price]*fact_events[quantity_sold_before_promo]

![Image](https://github.com/user-attachments/assets/2b9babe8-2ee2-4f70-9028-2330fc7c265c)
        
A card visual was used to represent Total Revenue After promotions
       
        Total_Rev_After = fact_events[base_price]*fact_events[quantity_sold_after_promo]

![Image](https://github.com/user-attachments/assets/cdea7d8e-2174-4118-9547-e5ab0cbf1d37)

A card visual was used to represent Total Incremental Revenue After promotions (IR)

    IR = ((fact_events[quantity_sold_after_promo]*fact_events[base_price]) - (fact_events[quantity_sold_before_promo]*fact_events[base_price]))

![Image](https://github.com/user-attachments/assets/6e4f9340-e480-4283-b4bd-02fdcb7f68f9)

A card visual was used to represent Total Sold Unit Before Promotions
       
        Total Sold Unit Before = sum(fact_events[quantity_sold_before_promo])

![Image](https://github.com/user-attachments/assets/31f91d47-ad8d-41c8-b444-3977f2190abc)

A card visual was used to represent Total Unit Sold After Promotions

        Total Sold Unit After = sum(fact_events[quantity_sold_after_promo])
        

![Image](https://github.com/user-attachments/assets/250f86d3-2b8b-4247-b333-ad70b82d1568)

A Card visual was used to represent the Total Incremental Units Sold After Promotions (ISU)

        ISU = [quantity_sold_after_promo] - fact_events[quantity_sold_before_promo]
        

![Image](https://github.com/user-attachments/assets/6ff61880-a08b-4548-a2ed-fa82d2f6c535)
- Step 11 : A bar chart was added to the report design area, representing the revenue in each city before and after the promotion. The field named "City" was used for categorization to compare store performance across different locations. 
- Step 12 : A bar chart was created to display the top 5 stores by IR (Incremental Revenue), highlighting the stores that achieved the highest revenue growth after the promotion.

- Step 13 : I created a bar chart displaying the bottom 5 stores by IR (Incremental Revenue) to highlight the least-performing stores after the promotion.
 
 
 - Step 18 : The report was then published to Power BI Service.
 
 
![Publish_Message](https://user-images.githubusercontent.com/102996550/174094520-3a845196-97e6-4d44-8760-34a64abc3e77.jpg)

# Snapshot of Dashboard (Power BI Service)

![Image](https://github.com/user-attachments/assets/1f355efa-4c23-4b53-88c8-6aaa51f0b94b)

 
 # Report Snapshot (Power BI DESKTOP)

 
![Image](https://github.com/user-attachments/assets/88c5de65-ece9-4bd5-ab42-e58598450d30)

# Insights

A single page report was created on Power BI Desktop & it was then published to Power BI Service.

Following inferences can be drawn from the dashboard;

###  Total Number of Stores = 50

  Total Revenue Before Promotions = 141 M

  Total Revenue After Promotions = 348 M
  
  Incremental Revenue After the promotion = 207 M

Revenue increased from 141M to 348M after the promotion, showing a 147% growth. 

Bengaluru led in revenue, with 32.94M before the promotion, making up 23.41% of total revenue.

Trivandrum had the lowest pre-promotion revenue at 3.2M, 928.90% lower than Bengaluru.

Revenue before and after the promotion showed a strong positive correlation, indicating that stores with higher initial revenue also performed well post-promotion.

Bengaluru saw the highest absolute revenue growth, with an increase of 50.76M after the promotion, highlighting its strong market response. 

