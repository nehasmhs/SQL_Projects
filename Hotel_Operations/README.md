# Hotel Operations Analysis

## Project Overview
LuxurStay Hotels is a major international hotel chain serving both business and leisure travellers across key cities worldwide. The chain prides itself on delivering exceptional customer service.  

Recently, management has received complaints regarding slow room service in certain hotel branches. These complaints have started to impact overall customer satisfaction, which has dropped from the target rating of **4.5**.  

As part of the Operations team, this project focuses on analyzing hotel performance, identifying branches with the worst service issues, and providing actionable insights to improve customer satisfaction.

---

## Objective
The main goals of this analysis are:

- Identify hotel branches and services with below-target customer satisfaction.  
- Evaluate response times for various hotel services.  
- Highlight specific areas (services and locations) requiring immediate improvement.  
- Provide insights to assist the Head of Operations in decision-making and resource allocation.

---

## Data
The analysis is based on data collected from customer feedback and service requests. Only records with feedback ratings are included.  

**Key tables:**

- `branch` – Details of hotel branches, including location, staff, and rooms.  
- `services` – Information about services offered (e.g., Meal, Laundry, Room Service).  
- `customer_requests` – Individual service requests with timestamps, branch, service, and customer rating.

---

## Analyses Performed

### Task 1 – Data Cleaning
- Cleaned the `branch` table by:
  - Replacing missing locations with `"Unknown"`.  
  - Replacing missing or invalid room counts with a default of `100`.  
  - Replacing missing staff counts with `total_rooms * 1.5`.  
  - Ensuring `opening_date` is within 2000–2023.  
  - Defaulting missing `target_guests` to `"Leisure"`.

**Output:** `clean_branch_data`

---

### Task 2 – Average & Maximum Service Duration
- Calculated **average** and **maximum** time taken for each service at each branch.  
- Rounded values to two decimal places.

**Output:** `average_time_service`  

---

### Task 3 – Targeted Services in EMEA and LATAM
- Filtered for **Meal** and **Laundry** services in **EMEA** and **LATAM** regions.  
- Returned service descriptions, branch IDs, locations, request IDs, and ratings.

**Output:** `target_hotels`  

---

### Task 4 – Low Performing Services
- Identified branch-service combinations where the **average rating is below 4.5**.  
- Returned service ID, branch ID, and average rating (rounded to 2 decimals).

**Output:** `average_rating`  

---

## Conclusion
This project enables the Head of Operations to:

- Pinpoint underperforming hotel branches and services.  
- Assess the impact of slow service on customer satisfaction.  
- Focus improvement efforts on high-priority regions and services.  

By leveraging this analysis, LuxurStay Hotels can take informed actions to enhance operational efficiency and maintain high customer satisfaction across its branches.

