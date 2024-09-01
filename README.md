# DataSet Link : https://drive.google.com/drive/folders/12vzVQyQxQYAb9epTM7xOGKdL6cZkVjc4?usp=drive_link
# Dunnhumby - The Complete Journey

## Context
Dunnhumby, a global leader in customer data science and analytics, specializes in empowering businesses to be customer-first by leveraging data-driven insights. With deep expertise in one of the world's most competitive markets — retail — Dunnhumby helps businesses navigate the complexities of multi-dimensional data to understand and serve their customers better. Their expertise spans across industries, including grocery retail, retail pharmacy, financial services, and consumer brands.

This business case focuses on analyzing customer behavior using household-level transaction data spanning over two years. The dataset comprises:

- **Household-level transactions**: Data from a group of 2,500 households who are frequent shoppers at a specific retailer.
- **Comprehensive purchase data**: All purchases within the store are considered, not limited to specific categories.
- **Demographics and marketing data**: Demographic information and direct marketing contact history are available for select households.

![image](https://github.com/user-attachments/assets/59f473e0-0882-4e03-aad5-bc1a977a81ab)

## Analysis Overview
The following analyses were performed to derive insights from the data:

1. **Order Size Segmentation**: Categorize orders into small (0-5 USD), medium (5-10 USD), or large (10+ USD) based on order value.
   
2. **Top Stores by Weekly Foot Traffic**: Identify the top 3 stores with the highest foot traffic for each week, where foot traffic is defined by the number of customers transacting.

3. **Customer Profiling**: Develop a basic customer profile including first and last visit dates, number of visits, average money spent per visit, and total money spent, sorted by the highest average spend.

4. **Single Customer Analysis**: Analyze the most spending customer (who has available demographic data), showing both demographic and profiling data.

5. **Product Affinity Analysis**: Determine which products (based on the `SUB_COMMODITY_DESC` field) are most frequently bought together.

6. **Household Shopping Behavior**: Identify the weeks during which each household shops and calculate their cumulative spending over time using a "sum over partition" approach.

7. **Weekly Revenue Per Account (RPA) Change**: Calculate the weekly change in RPA (spending by each customer compared to the previous week) using the `LAG` function.

8. **Returning Customers Analysis**: Determine the number and percentage of returning customers for each week.

9. **Quarterly Sales Analysis**: Perform a sales comparison by calculating the total sales amount for each quarter (creating a new quarter column using a CASE statement for 12-week periods).

10. **Store Sales Over Time**: Analyze how sales for individual stores change over different quarters.

11. **Customer Churn Analysis**: Calculate customer churn for each quarter, where churned customers are those who never shop again after that quarter.

12. **Customer Retention Analysis**: Identify retained customers for each quarter, defined as households that were present in both previous and current quarters.

13. **Customer Lifetime Value (CLV) Calculation**: Calculate CLV for different age groups using the following formula:
   - **Average Purchase Value**: Total value of all purchases over a time frame, divided by the number of purchases in that period.
   - **Average Purchase Frequency**: Number of purchases in a time period divided by the number of individual customers who made transactions.
   - **Customer Value**: Average purchase frequency multiplied by the average purchase value.
   - **Average Customer Lifespan**: Average length of time a customer continues buying from the retailer.
   - **CLV**: `Customer Value x Average Customer Lifespan`

## Conclusion
This comprehensive analysis provides deep insights into customer behavior, product affinity, sales trends, customer churn, and retention patterns. These insights can help businesses make data-driven decisions to enhance customer experiences and improve overall business performance.

