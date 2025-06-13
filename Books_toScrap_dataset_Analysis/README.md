
# 📘 Book Dataset Analysis – Web Scraping, ML, and Power BI Dashboard

Books Dataset scraped from Books.ToScrap.com website for Analysis and creating Dashboard 

This project showcases a complete data pipeline, from web scraping to data analysis and interactive dashboarding. It aims to provide key business insights into a book dataset scraped from an online bookstore.


---

## 🔗 Project Overview

**Steps Involved:**

1. **🕸 Web Scraping (Python)**  
   Scraped book data such as title, price, stock availability, and ratings from a website using `requests`, `BeautifulSoup`, and `pandas`.

2. **📊 EDA & Preprocessing**  
   - Cleaned and processed data
   - Extracted structured features: numeric price, stock status, numeric rating
   - Saved final cleaned dataset as `.csv`

3. **🤖 Machine Learning Model**  
   Trained basic models to predict book price categories or availability using scikit-learn.

4. **📈 Power BI Dashboard**  
   Built an interactive dashboard to visualize:
   - Total books
   - Average price
   - Book counts by rating
   - Price distribution (pie chart)
   - Average price by rating
   - Top 10 most expensive books
   - Matrix of ratings vs price categories

---

## 📂 Files Included

- `web_scrap_1.ipynb` – Jupyter notebook for scraping & cleaning
- `Book_Dataset_Dashboard.pbix` – Power BI dashboard file
- `screenshots/` – Dashboard preview images
- `README.md` – Project summary

---

## 📸 Dashboard Preview

Dashboard Screenshot:
![Screenshot 2025-06-12 163517](https://github.com/user-attachments/assets/4b9284c3-c874-4ccd-9dff-945a80ab72b0)


---

## 🔍 Key Insights from Dashboard

- Most books are rated **One or Two stars**
- Average price is approximately **₹10.16**
- A majority of books are marked as **Out of Stock**
- Ratings **don’t strongly correlate** with price
- A few premium books are priced significantly higher

---

## 🚀 Tools & Technologies

- **Python** – Web Scraping & EDA
- **BeautifulSoup**, **pandas**, **matplotlib**, **scikit-learn**
- **Power BI** – Dashboard creation & visualization

---

## 📬 Contact

Feel free to connect on LinkedIn: www.linkedin.com/in/sagar-wagare-1495532b3 or fork this repo if you find it helpful!

---

