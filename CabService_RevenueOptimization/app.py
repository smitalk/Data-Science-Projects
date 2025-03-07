from flask import Flask, render_template, request, redirect
import mysql.connector

app = Flask(__name__)

# MySQL Connection
db = mysql.connector.connect(
    host="localhost",  # Change if necessary
    user="root",
    password="Nagpur@30",
    database="CabServiceDB"
)
cursor = db.cursor(dictionary=True)

@app.route('/')
def index():
    # Fetch Total Number of Drivers Grouped by Zone
    cursor.execute("SELECT location_zone, COUNT(*) AS total_drivers FROM Drivers GROUP BY location_zone")
    total_drivers_by_zone = cursor.fetchall()

    # Fetch Total Number of Bookings Grouped by Zone and Service Type
    cursor.execute("""
        SELECT b.location_zone, s.service_type, COUNT(*) AS total_bookings
        FROM Bookings b
        JOIN Services s ON b.service_id = s.service_id
        GROUP BY b.location_zone, s.service_type
    """)
    total_bookings_by_zone = cursor.fetchall()

    # Fetch Average Acceptance Rate Grouped by Zone and Service Type
    cursor.execute("""
        SELECT d.location_zone, s.service_type, AVG(da.acceptance_rate) AS avg_acceptance
        FROM Driver_Acceptance da
        JOIN Drivers d ON da.driver_id = d.driver_id
        JOIN Services s ON da.service_id = s.service_id
        GROUP BY d.location_zone, s.service_type
    """)
    avg_acceptance_by_zone = cursor.fetchall()

    # Fetch Revenue (Total Earnings) Grouped by Zone and Service Type
    cursor.execute("""
        SELECT b.location_zone, s.service_type, SUM(b.fare) AS revenue
        FROM Bookings b
        JOIN Services s ON b.service_id = s.service_id
        GROUP BY b.location_zone, s.service_type
        ORDER BY revenue DESC
    """)
    revenue_by_zone = cursor.fetchall()

    return render_template('index.html', 
                           total_drivers_by_zone=total_drivers_by_zone, 
                           total_bookings_by_zone=total_bookings_by_zone, 
                           avg_acceptance_by_zone=avg_acceptance_by_zone, 
                           revenue_by_zone=revenue_by_zone)

# Search Drivers by Name or Zone
@app.route('/search_drivers', methods=['GET'])
def search_drivers():
    query = request.args.get('query', '')
    search_sql = """
        SELECT * FROM Drivers 
        WHERE name LIKE %s OR location_zone LIKE %s
    """
    cursor.execute(search_sql, (f"%{query}%", f"%{query}%"))
    results = cursor.fetchall()
    
    return render_template('search_drivers.html', drivers=results, query=query)

# Filter Bookings by Date
@app.route('/filter_bookings', methods=['GET'])
def filter_bookings():
    start_date = request.args.get('start_date', '')
    end_date = request.args.get('end_date', '')

    filter_sql = "SELECT * FROM Bookings WHERE DATE(booking_time) BETWEEN %s AND %s"
    
    if start_date and end_date:
        cursor.execute(filter_sql, (start_date, end_date))
        results = cursor.fetchall()
    else:
        results = []
    
    return render_template('filter_bookings.html', bookings=results, start_date=start_date, end_date=end_date)


# Display Drivers
@app.route('/drivers')
def show_drivers():
    cursor.execute("SELECT * FROM Drivers")
    drivers = cursor.fetchall()
    return render_template('drivers.html', drivers=drivers)

# Display Bookings
@app.route('/bookings')
def show_bookings():
    cursor.execute("SELECT * FROM Bookings")
    bookings = cursor.fetchall()
    return render_template('bookings.html', bookings=bookings)

# Display Reports from Views
@app.route('/reports')
def reports():
    cursor.execute("SELECT * FROM Driver_Performance")
    driver_performance = cursor.fetchall()
    
    cursor.execute("SELECT * FROM Service_Demand")
    service_demand = cursor.fetchall()
    
    return render_template('reports.html', driver_performance=driver_performance, service_demand=service_demand)

# Highest Paid Drivers Page
@app.route('/highest_paid_drivers')
def highest_paid_drivers():
    cursor.execute("SELECT * FROM Highest_Paid_Drivers")  # Using the View
    drivers = cursor.fetchall()
    return render_template('highest_paid_drivers.html', drivers=drivers)

# Driver Acceptance Performance Page
@app.route('/driver_acceptance_performance')
def driver_acceptance_performance():
    cursor.execute("SELECT * FROM Driver_Acceptance_Performance")  # Using the View
    performance = cursor.fetchall()
    return render_template('driver_acceptance_performance.html', performance=performance)

# Services Page
@app.route('/services')
def services():
    cursor.execute("SELECT * FROM Services")
    services = cursor.fetchall()
    return render_template('services.html', services=services)

if __name__ == '__main__':
    app.run(debug=True)
