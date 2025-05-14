import pymysql
from pymysql.err import MySQLError
import csv
import pandas as pd

def convert_data(file_name):
    with open(file_name, 'rb') as file:
        binary_data = file.read()
    return binary_data

# Function to connect to the database
def connect():
    df = pd.read_csv('Credentials.csv', header=None)
    host,user,password,db = df[0].tolist()
    conn = pymysql.connect(host=host, user=user, password=password, database=db,
                           cursorclass=pymysql.cursors.DictCursor)
    with conn.cursor() as cur:
        cur.execute("SELECT DATABASE()")
        print("Connected to:", cur.fetchone())
    return conn


# Generic helper to fill tables from CSV with images
def _fill_from_csv_image(table, columns, csv_path):
    all_cols = columns + ['image']
    placeholders = ", ".join(["%s"] * len(all_cols))
    cols = ", ".join(all_cols)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn = connect()
    try:
        cur = conn.cursor()
        with open(csv_path, newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader) # skip header
            for row in reader:
                try:
                    if len(row) != len(columns) + 1:
                        continue
                    # Convert '' → None so MySQL sees NULL, not an invalid integer
                    clean = [None if cell == '' else cell for cell in row[:-1]]
                    img = row[-1]
                    try:
                        raw_img = convert_data(img)
                        bin_img = pymysql.Binary(raw_img)
                    except Exception as a:
                        bin_img = None
                    data_cols = clean + [bin_img]
                    cur.execute(sql, data_cols)
                    conn.commit()   # commit *before* closing
                except MySQLError as l:
                    print(f"MySQL error: {l}")
                    continue
    except Exception as e:
        print(f"Error populating {table}:", e)
    finally:
        cur.close()
        conn.close()
        print(f"Finished {table}")

# Generic helper to fill tables from CSV
def _fill_from_csv(table, columns, csv_path):
    placeholders = ", ".join(["%s"] * len(columns))
    cols = ", ".join(columns)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn = connect()
    try:
        cur = conn.cursor()
        with open(csv_path, newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader)  # skip header
            for row in reader:
                try:
                    if len(row) != len(columns):
                        continue
                    # Convert '' → None so MySQL sees NULL, not an invalid integer
                    clean = [None if cell == '' else cell for cell in row]
                    cur.execute(sql, clean)
                    conn.commit()   # commit *before* closing
                except MySQLError as l:
                    print(f"MySQL error: {l}")
                    continue
    except Exception as e:
        print(f"Error populating {table}:", e)
    finally:
        cur.close()
        conn.close()
        print(f"Finished {table}")

# Helper to fill seller_queue from CSV
def _fill_from_csv_seller_queue(table, columns, csv_path):
    placeholders = ", ".join(["%s"] * len(columns))
    cols = ", ".join(columns)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn = connect()
    try:
        cur = conn.cursor()
        # Άνοιγμα και ανάγνωση του CSV
        with open('seller_queue.csv', mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    owner_id=row['seller_id']
                    ticket_id=row['ticket_id']
                    # Κλήση stored procedure για κάθε γραμμή
                    cur.callproc('insert_into_seller_queue', (int(owner_id),int(ticket_id)))
                    conn.commit()   # commit *before* closing
                except MySQLError as l:
                    print(f"MySQL error: {l}")
                    continue
    except Exception as e:
        print(f"Error populating {table}:", e)
    finally:
        cur.close()
        conn.close()
        print(f"Finished {table}")

# Function to generate the DML file
def _dump_from_csv(table, columns, csv_path, dump_path):
    placeholders = ", ".join(["%s"] * len(columns))
    cols = ", ".join(columns)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn = connect()
    with conn.cursor() as cur, open(dump_path, "a", encoding="utf-8") as dump: # Open in append mode to write at the end
        with open(csv_path, newline='', encoding="utf-8") as f:
            reader = csv.reader(f)
            next(reader)
            for row in reader:
                if len(row) != len(columns):
                    continue
                clean = [None if cell == "" else cell for cell in row]
                full_sql = cur.mogrify(sql, clean) + ";"
                dump.write(full_sql + "\n")
    cur.close()
    conn.close()
    print(f"Dumped INSERTs for {table} to {dump_path}")

# Function to generate the DML file for Images
def _dump_from_csv_image(table, columns, csv_path, dump_path):
    all_cols = columns + ['image']
    placeholders = ", ".join(["%s"] * len(all_cols))
    cols = ", ".join(all_cols)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    conn = connect()
    with conn.cursor() as cur, open(dump_path, "a", encoding="utf-8") as dump: # Open in append mode to write at the end
        with open(csv_path, newline='', encoding="utf-8") as f:
            reader = csv.reader(f)
            next(reader)
            for row in reader:
                if len(row) != len(columns) + 1:
                    continue
                clean = [None if cell == '' else cell for cell in row[:-1]]
                img = row[-1]
                try:
                    raw_img = convert_data(img)
                    bin_img = pymysql.Binary(raw_img)
                except Exception as a:
                    bin_img = None
                data_cols = clean + [bin_img]
                full_sql = cur.mogrify(sql, data_cols) + ";"
                dump.write(full_sql + "\n")
    cur.close()
    conn.close()
    print(f"Dumped INSERTs for {table} to {dump_path}")

# Fill functions for each table
def fill_location(): _fill_from_csv('location',
    ['address','latitude','longitude','city','country','continent','image'],
    'location.csv')

def fill_festival(): _fill_from_csv('festival',
    ['year','start_date','end_date','location_id','image'],
    'festival.csv')

def fill_stage(): _fill_from_csv('stage',
    ['name','description','max_capacity','equipment','image'],
    'stage.csv')

def fill_event(): _fill_from_csv('event',
    ['festival_id','stage_id','event_date','start_time','end_time'],
    'event.csv')

def fill_staff_role(): _fill_from_csv('staff_role',
    ['role_name'],
    'staff_role.csv')

def fill_experience_level(): _fill_from_csv('experience_level',
    ['level_name'],
    'experience_level.csv')

def fill_staff(): _fill_from_csv('staff',
    ['name','age','role_id','level_id','image'],
    'staff.csv')

def fill_staff_schedule(): _fill_from_csv('staff_schedule',
    ['staff_id','event_id'],
    'staff_schedule.csv')

def fill_genre(): _fill_from_csv('genre',
    ['genre_name'],
    'genre.csv')

def fill_subgenre(): _fill_from_csv('subgenre',
    ['subgenre_name','genre_id'],
    'subgenre.csv')

def fill_artist(): _fill_from_csv('artist',
    ['artist_name','artist_lastname','stage_name','DOB','website','instagram','image'],
    'artist.csv')

def fill_band(): _fill_from_csv('band',
    ['band_name','date_of_creation','website','instagram','genre_id','subgenre_id','image'],
    'band.csv')

def fill_artist_band(): _fill_from_csv('artist_band',
    ['band_id','artist_id'],
    'artist_band.csv')

def fill_artist_genre(): _fill_from_csv('artist_genre',
    ['artist_id','genre_id'],
    'artist_genre.csv')

def fill_artist_subgenre(): _fill_from_csv('artist_subgenre',
    ['artist_id','subgenre_id'],
    'artist_subgenre.csv')

def fill_perf_kind(): _fill_from_csv('perf_kind',
    ['kind_name'],
    'perf_kind.csv')

def fill_perf_type(): _fill_from_csv('perf_type',                               
    ['type_name'],
    'perf_type.csv')

def fill_performance(): _fill_from_csv('performance',
    ['perf_time','duration','kind_id','type_id','artist_id','band_id','event_id'],
    'performance.csv')

def fill_payment_method(): _fill_from_csv('payment_method',
    ['pm_name'],
    'payment_method.csv')

def fill_owner(): _fill_from_csv('owner',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','total_charge','image'],
    'owner.csv')

def fill_ticket_category(): _fill_from_csv('ticket_category',
    ['cat_name'],
    'ticket_category.csv')

def fill_ticket(): _fill_from_csv('ticket',
    ['ticket_category','purchase_date','cost','method_of_purchase','activated','event_id','owner_id'],
    'ticket.csv')

def fill_buyer(): _fill_from_csv('buyer',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','number_of_desired_tickets','image'],
    'buyer.csv')

def fill_seller_queue(): _fill_from_csv_seller_queue('seller_queue',
    ['seller_id','ticket_id'],
    'seller_queue.csv')

def fill_buyer_queue(): _fill_from_csv('buyer_queue',
    ['buyer_id','interest_datetime','ticket_id','event_id','ticket_category','sold'],
    'buyer_queue.csv')

def fill_review(): _fill_from_csv('review',
    ['ticket_id','interpretation','sound_and_lighting','stage_presence','organization','overall_impression','review_date','performance_id'],
    'review.csv')

# Dump functions for each table for DML
def dump_location(): _dump_from_csv('location',
    ['address','latitude','longitude','city','country','continent','image'],
    'location.csv',
    '../sql/load.sql')

def dump_festival(): _dump_from_csv('festival',
    ['year','start_date','end_date','location_id','image'],
    'festival.csv',
    '../sql/load.sql')

def dump_stage(): _dump_from_csv('stage',
    ['name','description','max_capacity','equipment','image'],
    'stage.csv',
    '../sql/load.sql')

def dump_event(): _dump_from_csv('event',
    ['festival_id','stage_id','event_date','start_time','end_time'],
    'event.csv',
    '../sql/load.sql')
    
def dump_staff_role(): _dump_from_csv('staff_role',
    ['role_name'],
    'staff_role.csv',
    '../sql/load.sql')

def dump_experience_level(): _dump_from_csv('experience_level',
    ['level_name'],
    'experience_level.csv',
    '../sql/load.sql')

def dump_staff(): _dump_from_csv('staff',
    ['name','age','role_id','level_id','image'],
    'staff.csv',
    '../sql/load.sql')

def dump_staff_schedule(): _dump_from_csv('staff_schedule',
    ['staff_id','event_id'],
    'staff_schedule.csv',
    '../sql/load.sql')

def dump_genre(): _dump_from_csv('genre',
    ['genre_name'],
    'genre.csv',
    '../sql/load.sql')

def dump_subgenre(): _dump_from_csv('subgenre',
    ['subgenre_name','genre_id'],
    'subgenre.csv',
    '../sql/load.sql')

def dump_artist(): _dump_from_csv('artist',
    ['artist_name','artist_lastname','stage_name','DOB','website','instagram','image'],
    'artist.csv',
    '../sql/load.sql')

def dump_band(): _dump_from_csv('band',
    ['band_name','date_of_creation','website','instagram','genre_id','subgenre_id','image'],
    'band.csv',
    '../sql/load.sql')

def dump_artist_band(): _dump_from_csv('artist_band',
    ['band_id','artist_id'],
    'artist_band.csv',
    '../sql/load.sql')

def dump_artist_genre(): _dump_from_csv('artist_genre',
    ['artist_id','genre_id'],
    'artist_genre.csv',
    '../sql/load.sql')

def dump_artist_subgenre(): _dump_from_csv('artist_subgenre',
    ['artist_id','subgenre_id'],
    'artist_subgenre.csv',
    '../sql/load.sql')

def dump_perf_kind(): _dump_from_csv('perf_kind',
    ['kind_name'],
    'perf_kind.csv',
    '../sql/load.sql')
    
def dump_perf_type(): _dump_from_csv('perf_type',                               
    ['type_name'],
    'perf_type.csv',
    '../sql/load.sql')

def dump_performance(): _dump_from_csv('performance',
    ['perf_time','duration','kind_id','type_id','artist_id','band_id','event_id'],
    'performance.csv',
    '../sql/load.sql')

def dump_payment_method(): _dump_from_csv('payment_method',
    ['pm_name'],
    'payment_method.csv',
    '../sql/load.sql')

def dump_owner(): _dump_from_csv('owner',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','total_charge','image'],
    'owner.csv',
    '../sql/load.sql')

def dump_ticket_category(): _dump_from_csv('ticket_category',
    ['cat_name'],
    'ticket_category.csv',
    '../sql/load.sql')

def dump_ticket(): _dump_from_csv('ticket',
    ['ticket_category','purchase_date','cost','method_of_purchase','activated','event_id','owner_id'],
    'ticket.csv',
    '../sql/load.sql')

def dump_buyer(): _dump_from_csv('buyer',
    ['first_name','last_name','age','phone_number','method_of_purchase','payment_info','number_of_desired_tickets','image'],
    'buyer.csv',
    '../sql/load.sql')

def dump_seller_queue(): _dump_from_csv('seller_queue',
    ['seller_id','ticket_id'],
    'seller_queue.csv',
    '../sql/load.sql')

def dump_buyer_queue(): _dump_from_csv('buyer_queue',
    ['buyer_id','interest_datetime','ticket_id','event_id','ticket_category','sold'],
    'buyer_queue.csv',
    '../sql/load.sql')

def dump_review(): _dump_from_csv('review',
    ['ticket_id','interpretation','sound_and_lighting','stage_presence','organization','overall_impression','review_date','performance_id'],
    'review.csv',
    '../sql/load.sql')

if __name__ == "__main__":
    fill_location()
    fill_festival()
    fill_stage()
    fill_staff_role()
    fill_experience_level()
    fill_staff()
    fill_event()
    #fill_staff_schedule()
    fill_genre()
    fill_subgenre()
    fill_artist()
    fill_band()
    fill_artist_band()
    fill_artist_genre()
    fill_artist_subgenre()
    fill_perf_kind()
    fill_perf_type()
    fill_performance()
    fill_payment_method()
    fill_owner()
    fill_ticket_category()
    fill_ticket()
    fill_buyer()
    fill_seller_queue()
    fill_buyer_queue()
    fill_review()
    print("All tables populated.")

    # Run (uncomment) only when you want to change the DML inserts
'''
    dump_location()
    dump_festival()
    dump_stage()
    dump_staff_role()
    dump_experience_level()
    dump_staff()
    dump_event()
    #dump_staff_schedule()
    dump_genre()
    dump_subgenre()
    dump_artist()
    dump_band()
    dump_artist_band()
    dump_artist_genre()
    dump_artist_subgenre()
    dump_perf_kind()
    dump_perf_type()
    dump_performance()
    dump_payment_method()
    dump_owner()
    dump_ticket_category()
    dump_ticket()
    dump_buyer()
    dump_seller_queue()
    dump_buyer_queue()
    dump_review()
    print("All inserts to DML.")
'''