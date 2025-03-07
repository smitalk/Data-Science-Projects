\# Cab Service Optimization System

\#\# Project Overview  
This Flask-based application integrates with MySQL to analyze driver performance, service demand, and revenue. The system provides:  
\- Driver and service management  
\- Ride booking functionality  
\- Revenue and acceptance rate insights

\#\#\# Project Structure

- app.py \[This contains the main python code to run html application\]  
- templates \[This contains all HTML code to render UI\]  
  - index.html  
  - bookings.html  
  - driver\_acceptance\_performance.html  
  - drivers.html  
  - filter\_bookings.html  
  - highest\_paid\_drivers.html  
  - reports.html  
  - search\_drivers.html  
  - services.html  
- requirements.txt \[Requirements for python app\]  
- Kamdi\_Smital\_Project.sql \[All SQL queries used\]  
- data \[this contain all csv with data\]  
  - bookings.csv  
  - driver\_acceptance.csv  
  - drivers.csv  
  - services.csv

\#\# Installation Instructions

\#\#\# Step 1: Install Dependencies  
Ensure Python 3+ is installed, then install required libraries:  
\`\`\`sh  
pip install \-r requirements.txt  
\`\`\`

\#\#\# Step 2: Setup MySQL Database  
1\. Open MySQL and run:  
\`\`\`sql  
source database\_setup.sql;  
\`\`\`

2\. Import the CSV data into MySQL:  
\`\`\`sql  
LOAD DATA INFILE '/path/to/drivers.csv' INTO TABLE Drivers  
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\\n' IGNORE 1 ROWS;  
\`\`\`  
(Repeat for Services, Bookings, and Driver\_Acceptance tables.)

\#\#\# Step 3: Run the Flask Application  
Start the server by running:  
\`\`\`sh  
python app.py  
\`\`\`

\#\#\# Step 4: Open the Web App(Chrome/Safari)  
Once the server is running, open:  
\`\`\`  
http://127.0.0.1:5000/  
\`\`\`

\#\# Features  
\- Search for drivers by name or zone  
\- Filter bookings by date range  
\- View highest-paid drivers  
\- Analyze driver acceptance rates  
\- Interactive dashboard for business insights

\#\# All SQL queries used to create table views, procedure, trigger, select and manipulate data are present in kamdi\_smital\_project.sql file.   
